%% Feel free to use, reuse and abuse the code in this file.

%% @doc EventSource emitter.
-module(eventsource_h).
-behavior(cowboy_handler).
-export([init/2]).
-export([info/3]).
-export([terminate/3]).
-record (state,{sender_pid,tab,target}).

init(Req, Target) ->
	Table = ets:new(?MODULE,[]),
	process_flag(trap_exit, true),

       %<<X:64/big-unsigned-integer>> = crypto:strong_rand_bytes(8),
       %_Random = lists:flatten(io_lib:format("~16.16.0b", [X])), %32=field width, Pad de zero, b est le Mod
       %Target = list_to_binary(_Random++"@mail-testing.com"),
        io:format("eventsource_h le email en random ~p ~n",[Target]),
        gproc:reg({p, l, Target}),

        turtle:publish(my_publisher,
                <<"pipe_cowboy">>,
                <<"">>,
                <<"text/json">>,
                Target,
                #{ delivery_mode => persistent }),

  	ets:insert(Table, {Target,30}),
	io:format("eventsource après le turtle:pulbsish ~n"),
        {ok, _SenderPid} = gen_consume:start_link(Target),
	io:format("eventsource après le gen_consume launch ~n"),

	Req0 = cowboy_req:stream_reply(200, #{
		<<"content-type">> => <<"text/event-stream">>
	}, Req),
	io:format("eventsource après le stream_reply 200 ~n"),

	%cowboy_req:stream_body("Hello\r\n", nofin, Req),
	io:format("eventsource après le cowboy_req_stream"),
	
	erlang:send_after(1000, self(), {message, Target, []}),
	State2 = #state{sender_pid=_SenderPid,tab=Table,target=Target},
	{cowboy_loop, Req0, State2}.

info({message, Msg,[]}, Req, State)  ->
	Table = State#state.tab,
	Target = State#state.target,
	%Target2 = list_to_binary("azerty51@mail-testing.com"),
	Counter = case ets:lookup(Table, Target) of
			[{Target,Balance}] -> _NewBalance = Balance - 1
	end,
	io:format("eventsource_h Target ~p ~n",[Target]),
	ets:insert(Table, {Target, Counter}),

	cowboy_req:stream_events(#{
		id => id(),
		%data => Msg
		data =>  integer_to_list(Counter)
	}, nofin, Req),
	erlang:send_after(1000, self(), {message,Msg,[]}),
	{ok, Req, State};
%info({message, _Msg,MM}, Req, State) when MM =:= 42  ->
%        io:format("eventsource_h CA MATCH ?"),
	%%Req1 = cowboy_req:stream_events(#{}, fin, Req),
        %io:format("eventsource_h le MM ~p ~n",[MM]),
	%{stop, Req1, State}.
info({'EXIT', _From, _Reason}, _Req,State) ->
	io:format("eventsource_h EXIT intervient la"),
	    {stop, {shutdown, partner_fled}, State};
info({error,Ref,MM}, Req, #state{sender_pid=_SenderPid}=State) when MM =:= 42  ->
        io:format("eventsource_h INFO/3 loop ~p ~n", [Ref]),
	Req1 = cowboy_req:stream_events(#{
	         id => id(),
		 data => integer_to_list(Ref)
		}, fin, Req),
	%{ok, Req1, State}.
	gen_server:stop(_SenderPid),
	{stop, Req1, State}.
id() ->
	integer_to_list(erlang:unique_integer([positive, monotonic]), 16).


terminate(_Reason, _Req, #state{sender_pid=_SenderPid}=_State) ->
	%timer:sleep(3000),
	io:format("eventsource_h terminate SenderPid ~p ~n",[_SenderPid]),
	io:format("eventsource_h terminate Reason ~p ~n",[_Reason]),
	io:format("eventsource_h terminate Req ~p ~n",[_Req]),
% 	gen_server:cast(_SenderPid, {_AdresseDeMerde,[]}),
	    ok.

%% Feel free to use, reuse and abuse the code in this file.

%% @doc EventSource emitter.
-module(eventsource_h).

-export([init/2]).
-export([info/3]).
-export([terminate/3]).
-record (state,{sender_pid}).

init(Req, _State) ->
        %gproc:reg({p, l, my_event_proc}),
	process_flag(trap_exit, true),
       <<X:64/big-unsigned-integer>> = crypto:strong_rand_bytes(8),
       Random = lists:flatten(io_lib:format("~16.16.0b", [X])), %32=field width, Pad de zero, b est le Mod
       Target = list_to_binary(Random++"@mail-testing.com"),
        io:format("eventsource_h le email en random ~p ~n",[Target]),

        turtle:publish(my_publisher,
                <<"pipe_cowboy">>,
                <<"">>,
                <<"text/json">>,
                Target,
		%<<"seb@mail-testing.com">>,
                #{ delivery_mode => persistent }),

        gproc:reg({p, l, Target}),
	
        %{ok, SenderPid} = gen_consume:start_link(Target),
        %gen_consume:start(Target),
        {ok, _SenderPid} = gen_consume:start(Target),

	Req0 = cowboy_req:stream_reply(200, #{
		<<"content-type">> => <<"text/event-stream">>
	}, Req),
	%erlang:send_after(1000, self(), {message, <<"seb@mail-testing.com">>, []}),
	erlang:send_after(1000, self(), {message, Target, []}),
	State2 = #state{sender_pid=_SenderPid},
	{cowboy_loop, Req0, State2}.

info({message, Msg,[]}, Req, State)  ->
	cowboy_req:stream_events(#{
		id => id(),
		data => Msg
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

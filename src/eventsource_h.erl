%% Feel free to use, reuse and abuse the code in this file.

%% @doc EventSource emitter.
-module(eventsource_h).
-behavior(cowboy_handler).
-export([init/2]).
-export([info/3]).
-export([terminate/3]).
-record (state,{sender_pid,tab,target}).

init(Req, _State) ->
	Table = ets:new(?MODULE,[]),
	%process_flag(trap_exit, true),
	#{peer := IdCouple} = Req,
	io:format("eventsource_h #peer IdCouple ~p ~n",[IdCouple]),
	Target = emptycouple(IdCouple),
	
        gproc:reg({p, l, Target}),

        turtle:publish(my_publisher,
                <<"pipe_cowboy">>,
                <<"">>,
                <<"text/json">>,
                Target,
                #{ delivery_mode => persistent }),

  	ets:insert(Table, {Target,59}),
        {ok, _SenderPid} = gen_consume:start(Target),

	Req0 = cowboy_req:stream_reply(200, #{
		<<"content-type">> => <<"text/event-stream">>
	}, Req),

	erlang:send_after(1000, self(), {message, Target, []}),
	State2 = #state{sender_pid=_SenderPid,tab=Table,target=Target},
	{cowboy_loop, Req0, State2}.

emptycouple(IdCouple) ->
	io:format("eventsource_h BADSTART ~n"),
	%	[{{{82,64,230,35},19026},<<"f69dfba6ba5c5fe9@mail-testing.com">>}]
	   If = case gen_server:call(store_and_dispatch, {query,IdCouple}) of
	            [] ->
		               <<"badstart">>;
	            _ ->
		               [{{{_,_,_,_},_},Target}] = gen_server:call(store_and_dispatch, {query,IdCouple}),
			       Target 
		end,
	If.

info({message, Msg,[]}, Req, State)  ->
	Table = State#state.tab,
	Target = State#state.target,
	Counter = case ets:lookup(Table, Target) of
			[{Target,Balance}] -> _NewBalance = Balance - 1
	end,
	%%LOG important pour LOOPER l'email random pour cible
	io:format("eventsource_h Target ~p ~n",[Target]),
	%%LOG
	ets:insert(Table, {Target, Counter}),

	cowboy_req:stream_events(#{
		id => id(),
		%data => Msg
		data =>  integer_to_list(Counter)
	}, nofin, Req),
	erlang:send_after(1000, self(), {message,Msg,[]}),
	{ok, Req, State};
info({'EXIT', _From, _Reason}, _Req,State) ->
	io:format("eventsource_h EXIT intervient la"),
	    {stop, {shutdown, partner_fled}, State};
info({error,Ref,MM}, Req, #state{sender_pid=_SenderPid}=State) when MM =:= 42  ->
        io:format("eventsource_h INFO/3 loop ~p ~n", [Ref]),
	Req1 = cowboy_req:stream_events(#{
	         id => id(),
		 data => integer_to_list(Ref)
		}, fin, Req),
	gen_server:stop(_SenderPid),
	{stop, Req1, State}.
id() ->
	integer_to_list(erlang:unique_integer([positive, monotonic]), 16).


terminate(Reason, Req, State) ->
	io:format("eventsource_h terminate Reason Req State ~p ~p ~p ~n",[Reason,Req,State]),
	    ok.

-module(hello_handler).
-behavior(cowboy_handler).
-export([init/2]).
-export([info/3]).
-record( state, { sender_pid,booked_queue}).

init(Req, _State) ->
	Id = cowboy_req:binding(id, Req),
	Self = self(),
        {ok, QBook} = gen_server:call(frequency, {allocate, Self}),
        {ok, _SenderPid} = gen_consume_score:start({Id,QBook}),
    %cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, [], Req),
	io:format("gen_consume_score QBook ~p ~n",[QBook]),
	%io:format("hello_handler Req ~p ~n",[Req]),
	io:format("hello_handler init STATE ~p ~n",[_State]),
       gproc:reg({p, l, Id}),
       %gproc:reg({p, l, my_event_proc2}),
    %{ok, Req, State}.
    State2 = #state{sender_pid=_SenderPid,booked_queue=QBook},
    {cowboy_loop, Req, State2,hibernate}.

info({message2, _Body}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->
	%io:format("hello_handler INFO/3 pick up from gen_consume_score ~p ~n",[Body]),
	%io:format("hello_handler INFO/3 Req ~p ~n",[Req]),
	io:format("hello_handler LA PAGE HTML S AFFICHE ! ~n"),
        gen_server:cast(frequency,{deallocate, _QBook}),
        cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, <<"Hello Erlang">>, Req),
	  %  cowboy_req:reply(200, #{}, Body, Req),
	gen_server:stop(SenderPid),
	        {stop, Req, State};
info(_Msg, Req, State) ->
	    {ok, Req, State, hibernate}.

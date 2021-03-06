-module(gen_consume).
-behaviour(gen_server).
%-export([start_link/1]).
-export([start/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
-include_lib("amqp_client/include/amqp_client.hrl").
-record (state,{sender_pid,addr,booked_queue}).
 
%start_link(Random) ->
start(Random) ->
	
%gen_server:start_link({local, ?MODULE}, ?MODULE, [Random], []).
gen_server:start( ?MODULE, Random, []).

init(Random) ->
	%io:format(">>>>> gen_consume INIT adresse RCPT random ~p ~n",[Random]),
	%process_flag(trap_exit, true),

	Self = self(),

        {ok, QBook} = gen_server:call(queuedistrib, {allocate, Self,Random}),
	io:format("gen_consume allocate QBook ~p ~n",[QBook]),
	io:format("gen_consume allocate Self ~p ~n",[Self]),


	F = fun(Key, ContentType, Payload, Header, _State) ->
		io:format("gen_consume la on recupere les Header depuis Rabbitmq ~n"),
		Self ! {Key, ContentType, Header, Payload},
		ack
	end,
InitState = #{},
Declarations = application:get_env(event_single, consume_declarations),
     {_, Dcls} = Declarations,
Amqp = #{
  %name => local_service,
  name => binary_to_atom(Random),
  connection => amqp_server,
  function => F,
  %function => fun _Mod:loop/4,
  handle_info => fun gen_consume:handle_info/2,
  init_state => InitState,
  subscriber_count => 1,
  prefetch_count => 1,
  passive => true,
  %consume_queue => <<"PUSH_EVERY_BOX">>,
  consume_queue => list_to_binary(QBook),
  declarations => Dcls
       },
{ok, _ServicePid} = turtle_service:start_link(Amqp),

State2 = #state{sender_pid=_ServicePid,addr=Random,booked_queue=QBook},
{ok, State2}.

handle_call({pub}, _From, State) -> {reply, ok, State+1}.

handle_cast({pub2}, State) -> {noreply, State}.

handle_info({ _,undefined,[{<<"To">>,longstr,_RdmAddress},{<<"Ref">>,signedint,Ref},_,_,_,_,_,_,_,_],_Hop}=_Unroll, #state{addr=Random,booked_queue=QBook}=State) when _RdmAddress =:= Random  -> 
	io:format("gen_consume HANDLE_INFO/3 QueueBooked ~p ~n",[QBook]),
	io:format("gen_consume HANDLE_INFO/3 Hop ~p ~n",[_Hop]),

        gproc:send({p, l, Random}, {error,Ref,42}),	
        gen_server:cast(queuedistrib,{deallocate, QBook}),
	{noreply, State};
handle_info({ _,undefined,[To,Ref,_,_,_,_,_,_,_,_],_}, #state{addr=_Random}=State) ->
	io:format("gen_consume handle_info qui matche pas. To & Ref ~p ~p ~n",[To,Ref]),
        {noreply, State}.


terminate(_Reason, _State) ->
io:format("gen_consume ~p stopping ~n",[?MODULE]),
ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

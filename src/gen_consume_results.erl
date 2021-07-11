-module(gen_consume_results).
-behaviour(gen_server).
%-export([start_link/1]).
-export([start/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
-record (state,{sender_pid,addr}).
-include_lib("amqp_client/include/amqp_client.hrl").
 
%start_link(AdresseDeMerde) ->
start({_AdresseDeMerde,_QBook}) ->
%gen_server:start_link({local, ?MODULE}, ?MODULE, [AdresseDeMerde], []).
%gen_server:start({local, ?MODULE}, ?MODULE, [AdresseDeMerde], []).
%gen_server:start(?MODULE, [<<"seb@mail-testing.com">>], []).
gen_server:start(?MODULE, {_AdresseDeMerde,_QBook}, []).

init({AdresseDeMerde,_QBook}) ->
	%io:format("gen_consume_results le Random pour discriminer le mess ~p ~n",[AdresseDeMerde]),
	process_flag(trap_exit, true),

	io:format("gen_consume_results ~p ~n",[_QBook]),
	Self = self(),

	G = fun(Key, ContentType, Payload, Header, _State) ->
		io:format("gen_consume_results la on recup les header depuis la queue RabbitMQ  ~n"),
		Self ! {Key, ContentType, Header, Payload},
		ack
	end,
InitState = #{},
Declarations = application:get_env(event_single, consume_declarations),
     {_, Dcls} = Declarations,
Amqp = #{
  name => list_to_atom(get_random_string(6, "abcdefghijklmnopqrstuvwz")),
  connection => amqp_server,
  function => G,
  %function => fun _Mod:loop/4,
  handle_info => fun gen_consume_results:handle_info/2,
  init_state => InitState,
  subscriber_count => 1,
  prefetch_count => 1,
  passive => true,
  %consume_queue => list_to_binary(QBook),
  consume_queue => <<"SCORE_EVERY_BOX">>,
  declarations => Dcls
		  
       },
{ok, _ServicePid} = turtle_service:start_link(Amqp),

%{ok, 0}.
State2 = #state{sender_pid=_ServicePid,addr=AdresseDeMerde},
{ok, State2}.

get_random_string(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(rand:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).

handle_call({pub}, _From, State) -> {reply, ok, State+1}.

handle_cast({pub2}, State) -> {noreply, State}.

handle_info({ _,undefined,[_,{<<"Ref">>,signedint,Ref},{<<"Dkim">>,longstr,Dkim},{<<"Date">>,longstr,Date},{<<"Ip">>,longstr,Ip},{<<"Serveur">>,longstr,Serveur},_,_,{<<"DKIM_VALID">>,signedint,Dkim_valid}],Hop}, #state{addr=AdresseDeMerde}=State) when Ref =:= AdresseDeMerde ->
%       gen_server:cast(_SenderPid, {_AdresseDeMerde,[]}),
   	%io:format("gen_consume_results on filtre en fonction du header Ref ~p ~n",[Ref]),
	%io:format("gen_consume_results le AdresseDeMerde ~p ~n",[AdresseDeMerde]),
	gproc:send({p, l, Ref}, {results_page,Dkim,Date,Ip,Serveur,Dkim_valid,Hop}),	
        {noreply, State};
handle_info({ _,undefined,[_,{<<"Ref">>,signedint,_Ref},_,_,_,_,_,_,_],_Hop}, #state{addr=_AdresseDeMerde}=State) ->
	%io:format(">>>>>>>> gen_consume handle_info match pas le Ref ~p ~n",[Ref]),
	%io:format(">>>>>>>> gen_consume handle_info match pas le Adresse_De_Merde ~p ~n",[AdresseDeMerde]),
	io:format("gen_consume_results handle_info qui matche pas ~n"),
        {noreply, State}.

terminate(_Reason, _State) ->
io:format("gen_consume_results ~p stopping ~n",[?MODULE]),
ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

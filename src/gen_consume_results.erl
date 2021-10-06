-module(gen_consume_results).
-behaviour(gen_server).
%-export([start_link/1]).
-export([start/1]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
-record (state,{sender_pid,id}).
-include_lib("amqp_client/include/amqp_client.hrl").
 
%start_link(Id) ->
start({_Id,QBook}) ->
%gen_server:start_link({local, ?MODULE}, ?MODULE, [Id], []).
%gen_server:start({local, ?MODULE}, ?MODULE, [Id], []).
%gen_server:start(?MODULE, [<<"seb@mail-testing.com">>], []).
gen_server:start(?MODULE, {_Id,QBook}, []).


init({Id,QBook}) ->
	io:format("gen_consume_results le Id pour discriminer le mess ~p ~n",[Id]),
	process_flag(trap_exit, true),

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
  consume_queue => list_to_binary(QBook),
  %consume_queue => <<"SCORE_EVERY_BOX">>,
  declarations => Dcls
		  
       },
{ok, _ServicePid} = turtle_service:start_link(Amqp),

%{ok, 0}.
State2 = #state{sender_pid=_ServicePid,id=Id},
{ok, State2}.


get_random_string(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(rand:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).

handle_call({pub}, _From, State) -> {reply, ok, State+1}.

handle_cast({pub}, #state{}) -> {noreply, #state{}}.

handle_info({ _,undefined,[_,{<<"Ref">>,signedint,Ref},{<<"Dkim">>,longstr,Dkim},{<<"Date">>,longstr,Date},{<<"Ip">>,longstr,Ip},{<<"Serveur">>,longstr,Serveur},{<<"SPF_PASS">>,signedint,Spf_pass},{<<"SPF_PASS">>,signedint,Spf2_pass},_,{<<"DKIM_VALID">>,signedint,Dkim_valid}],Hop}, #state{id=Id}=State) when Ref =:= Id ->
   	io:format("gen_consume_results Ref ~p ~n",[Ref]),
   	io:format("gen_consume_results Id ~p ~n",[Id]),
   	io:format("gen_consume_results Spf_pass ~p ~n",[Spf_pass]),
   	io:format("gen_consume_results Dkim_valid ~p ~n",[Dkim_valid]),
	gproc:send({p, l, Ref}, {results_page,Dkim,Date,Ip,Serveur,Spf_pass,Spf2_pass,Dkim_valid,Hop}),	
        {noreply, State};
handle_info({ _,undefined,[_,{<<"Ref">>,signedint,Ref},_,_,_,_,_,_,_,_],_Hop}, #state{id=Id}=State) when Id =:= 58 ->
%   	io:format("gen_consume_results BATARD Ref ~p ~n",[Ref]),
%   	io:format("gen_consume_results BATARD Id ~p ~n",[Id]),
%	%gproc:send({p, l, Id}, {results_null,<<"Dkim">>,<<"Date">>,<<"Ip">>,<<"Serveur">>,1,<<"hoppoeébpba">>}),	
	gproc:send({p, l, Ref}, {results_null,[]}),	
        {noreply, State};
handle_info({ _,undefined,[_,{<<"Ref">>,signedint,_Ref},_,_,_,_,_,_,_,_],_Hop}, #state{id=_Id}=State) ->
	io:format("gen_consume_results handle_info qui matche pas ~n"),
        {noreply, State}.

terminate(_Reason, _State) ->
io:format("gen_consume_results ~p stopping ~n",[?MODULE]),
ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

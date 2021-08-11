%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author Kevin Smith <kevin@opscode.com>
%% @copyright 2011 Opscode, Inc.

-module(gen_consume_amqphijack).

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {sender_pid}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->

	Self = self(),
		
	H = fun(Key, ContentType, Payload, Header, _State) ->
		io:format("gen_consume_results la on recup les header depuis la queue RabbitMQ  ~n"),
		Self ! {Key, ContentType, Header, Payload},
		ack
	end,

InitState = #{},
Declarations = application:get_env(event_single, consume_declarations),
     {_, Dcls} = Declarations,
Amqp = #{
  name => local_service,
  connection => amqp_server,
  function => H,
  %function => fun _Mod:loop/4,
  handle_info => fun gen_consume_amqphijack:handle_info/2,
  init_state => InitState,
  subscriber_count => 1,
  prefetch_count => 1,
  passive => true,
  consume_queue => <<"queue_hijack">>,
  declarations => Dcls
		  
       },
{ok, _ServicePid} = turtle_service:start_link(Amqp),

State2 = #state{sender_pid=_ServicePid},
{ok, State2}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

%handle_info({ _,undefined,[_,{<<"Ref">>,signedint,Ref},_,_,_,_,_,_,_],_Hop}, State) when BadReload =:= ok ->
handle_info({ _,undefined,[_,_,_,_,_,_,_,_,_],_Hop}, State) ->
  	io:format("AMQPHIJACK handle_info ~n"),
	gproc:send({p, l, amqphijack}, {results_null,[]}),	
	{noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions

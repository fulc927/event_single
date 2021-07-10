-module(store_and_dispatch).
-behaviour(gen_server).

-export([start/0, start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, stop/0, terminate/2]).
-export([code_change/3]).

start_link() ->
  gen_server:start_link({local, store_and_dispatch}, store_and_dispatch, [], []).

start() ->
  gen_server:start({local, store_and_dispatch}, store_and_dispatch, [], []).

init([]) ->
 State  = [],
  {ok, State}.

handle_cast({randomstring,{{A,B,C,D},E}=Couple,Target},State) ->
  	ets:insert(event_single_app, {Couple,Target}),
  	io:format("store_and_dispatch Couple ~p ~n",[Couple]),
  	io:format("store_and_dispatch Ip and Target ~p ~p ~p ~p ~p ~p ~n",[A,B,C,D,E,Target]),
  {noreply, State}.

handle_call({query,{{A,B,C,D},E}=Couple}, _From, State) ->
	io:format("store_and_dispatch query Couple ~p ~n",[Couple]),
	Reply = ets:lookup(event_single_app, {{A,B,C,D},E}), 
	io:format("store_and_dispatch Reply ~p ~n",[Reply]),
{reply, Reply, State}.


%handle_call(_Msg,_From,State) ->
%	{reply, ok,State}.

handle_info(_Msg, LoopData) ->
  {noreply, LoopData}.

stop() -> gen_server:cast(store_and_dispatch, stop).

terminate(_Reason, _LoopData) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.




%%% client api

%allocate() -> gen_server:call(frequency, {allocate, self()}).

%deallocate(Frequency) -> gen_server:cast(frequency, {deallocate, Frequency}).

% How to use
%
%
%c(frequency).
%gen_server:start({local, frequency}, frequency, [], []).
%
% frequency:allocate().
%
% frequency:deallocate(10).

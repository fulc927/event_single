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

handle_cast({insert,{{A,B,C,D},_E}=Couple,Target},State) ->
  	ets:insert(event_single_app, {{A,B,C,D},Target}),
	ets:insert(event_single_app2, {Couple,Target}),
	%Ligne de lookup test et facultative
	%Alurs = ets:lookup(event_single_app, {A,B,C,D}), 
	%io:format("Alurs? on lookup Couple ~p ~n",[Alurs]),
  	io:format("Alurs Ip and Target ~p ~p ~p ~p ~p ~p ~n",[A,B,C,D,_E,Target]),
  {noreply, State};
handle_cast({delete,{{A,B,C,D},_E}},State) ->
  	ets:delete(event_single_app,{A,B,C,D}),
	Alors = ets:lookup(event_single_app, {A,B,C,D}), 
	io:format("Alors? on lookup Couple ~p ~n",[Alors]),
  {noreply, State}.

handle_call({query,{{A,B,C,D},_E}=Couple}, _From, State) ->
	io:format("store_and_dispatch query Couple ~p ~n",[Couple]),
	%Reply = ets:lookup(event_single_app, {{A,B,C,D},E}), 
	Reply = ets:lookup(event_single_app, {A,B,C,D}), 
	io:format("store_and_dispatch Reply ~p ~n",[Reply]),
	% TEST NÉCESSAIRE À CE NIVEAU !!! si Reply = []
{reply, Reply, State};
handle_call({query2,{{A,B,C,D},E}=Couple}, _From, State) ->
	io:format("store_and_dispatch query Couple ~p ~n",[Couple]),
	Reply2 = ets:lookup(event_single_app2, {{A,B,C,D},E}), 
	io:format("store_and_dispatch Reply2 ~p ~n",[Reply2]),
{reply, Reply2, State}.

handle_info(_Msg, LoopData) ->
  {noreply, LoopData}.

stop() -> gen_server:cast(store_and_dispatch, stop).

terminate(_Reason, _LoopData) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

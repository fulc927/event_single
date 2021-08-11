-module(queuedistrib).
-behaviour(gen_server).

%-export([start/0, start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, stop/0, terminate/2]).
-export([start/0, start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).
-export([allocate/2, deallocate/2, code_change/3]).

start_link() ->
  gen_server:start_link({local, queuedistrib}, queuedistrib, [], []).

start() ->
  gen_server:start({local, queuedistrib}, queuedistrib, [], []).

init([]) ->
  %TABLE ETS pour amqphijacking
  ?MODULE = ets:new(?MODULE, [named_table, ordered_set, public]),
  
  Frequencies = {get_frequencies(), []},
  Frequencies2 = {get_frequencies2(), []},
  _Debug = superandom(Frequencies),
  {ok, {Frequencies,Frequencies2}}.

superandom(List_freq) ->
	{A,B} = List_freq,
C = [X ||{_,X} <- lists:sort([ {rand:uniform(), N} || N <- A])],
D = {C,B},
D.

get_frequencies() -> ["queue0","queue1", "queue2","queue3","queue4"].
get_frequencies2() -> ["queue5","queue6", "queue7","queue8","queue9"].

handle_call({allocate, Pid,Random}, _From, {Frequencies,F2}) ->
  %TABLE ETS pour amqphijacking
  ets:insert(?MODULE, {Pid,Random}),
  {NewFrequencies, Reply} = allocate(superandom(Frequencies), Pid),
  %% STRUCTURE DONNÉES de superandom(Frequencies) s’en inspirer {["queue2","queue1","queue4","queue7","queue3"],[{"queue0",<0.1013.0>}]}
  {Dispo,_} = NewFrequencies,
  io:format("queuedistrib QUEUE DISPO ~p ~n",[Dispo]),
  io:format("queuedistrib Reply ~p ~n",[Reply]),
  gen_server:cast(timeout, {makewait,Reply}), 
  {reply, Reply, {NewFrequencies,F2}};

handle_call({allocate2, Pid}, _From, {F,Frequencies2}) ->
  {NewFrequencies2, Reply} = allocate(superandom(Frequencies2), Pid),
  {reply, Reply, {F,NewFrequencies2}}.

handle_cast({deallocate, Freq}, {Frequencies,F2}) ->
  NewFrequencies = deallocate(Frequencies, Freq),
  {noreply, {NewFrequencies,F2}};

handle_cast({deallocate2, Freq}, {F,Frequencies2}) ->
  NewFrequencies2 = deallocate(Frequencies2, Freq),
  {noreply, {F,NewFrequencies2}}.
%handle_cast(stop, LoopData) ->
%    {stop, normal, LoopData}.

handle_info(_Msg, LoopData) ->
  {noreply, LoopData}.

%stop() -> gen_server:cast(queuedistrib, stop).

terminate(_Reason, _LoopData) ->
  ok.

allocate({[], Allocated}, _Pid) ->
  {{[], Allocated}, {error, no_frequency}};
allocate({[Freq|Free], Allocated}, Pid) ->
  {{Free, [{Freq, Pid}|Allocated]}, {ok, Freq}}.

deallocate({Free, Allocated}, Freq) ->
  NewAllocated = lists:keydelete(Freq, 1, Allocated),
  {[Freq|Free], NewAllocated}.

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

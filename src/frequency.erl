-module(frequency).
-behaviour(gen_server).

-export([start/0, start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, stop/0, terminate/2]).
%-export([allocate/0, deallocate/1, code_change/3]).
-export([allocate/2, deallocate/2, code_change/3]).

start_link() ->
  gen_server:start_link({local, frequency}, frequency, [], []).

start() ->
  gen_server:start({local, frequency}, frequency, [], []).

init([]) ->

  Frequencies = {get_frequencies(), []},
  Frequencies2 = {get_frequencies2(), []},
  Debug = superandom(Frequencies),
  io:format("frequency Debug ~p ~n",[Debug]),
  {ok, {Frequencies,Frequencies2}}.

superandom(List_freq) ->
 io:format("frequency superandom  List_freq ~p ~n",[List_freq]),
	{A,B} = List_freq,
 io:format("frequency superandom  A ~p ~n",[A]),
C = [X ||{_,X} <- lists:sort([ {rand:uniform(), N} || N <- A])],
 io:format("frequency superandom  C ~p ~n",[C]),
D = {C,B},
D.



get_frequencies() -> ["queue0","queue1", "queue2","queue3","queue4"].
get_frequencies2() -> ["queue5","queue6", "queue7","queue8","queue9"].

handle_call({allocate, Pid}, _From, {Frequencies,F2}) ->
  io:format("frequency handle_call/3 allocate Frequencies ~p ~n",[Frequencies]),
  {NewFrequencies, Reply} = allocate(superandom(Frequencies), Pid),
  io:format("frequency handle_call/3 Reply ~p ~n",[Reply]),
  {reply, Reply, {NewFrequencies,F2}};
handle_call({allocate2, Pid}, _From, {F,Frequencies2}) ->
  io:format("frequency handle_call/3 allocate Frequencies2 ~p ~n",[Frequencies2]),
  {NewFrequencies2, Reply} = allocate(superandom(Frequencies2), Pid),
  io:format("frequency handle_call/3 Reply2 ~p ~n",[Reply]),
  {reply, Reply, {F,NewFrequencies2}}.

handle_cast({deallocate, Freq}, {Frequencies,F2}) ->
  io:format("frequency handle_cast/2 deallocate frequence ~p ~n",[Freq]),
  NewFrequencies = deallocate(Frequencies, Freq),
  {noreply, {NewFrequencies,F2}};

handle_cast({deallocate2, Freq}, {F,Frequencies2}) ->
  io:format("frequency handle_cast/2 desalloue frequence2 ~p ~n",[Freq]),
  NewFrequencies2 = deallocate(Frequencies2, Freq),
  {noreply, {F,NewFrequencies2}};
handle_cast(stop, LoopData) ->
    {stop, normal, LoopData}.

handle_info(_Msg, LoopData) ->
  {noreply, LoopData}.

stop() -> gen_server:cast(frequency, stop).

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

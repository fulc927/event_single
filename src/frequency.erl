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
  {ok, Frequencies}.

get_frequencies() -> ["queue1", "queue2", "queue3","queue4"].

handle_call({allocate, Pid}, _From, Frequencies) ->
  io:format("frequency handle_call/3 allocate Frequencies ~p & Pid ~p ~n",[Frequencies,Pid]),
  {NewFrequencies, Reply} = allocate(Frequencies, Pid),
  io:format("frequency handle_call/3 attribue queue et repond a elcome ~p ~n",[Reply]),
  {reply, Reply, NewFrequencies}.

handle_cast({deallocate, Freq}, Frequencies) ->
  io:format("frequency handle_cast/2 desalloue frequence ~p ~n",[Freq]),
  NewFrequencies = deallocate(Frequencies, Freq),
  {noreply, NewFrequencies};
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

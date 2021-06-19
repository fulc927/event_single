%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(event_single_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

positive_fun(forward, Value) when Value > 0 ->
    {ok, Value};
positive_fun(forward, _) ->
    {error, not_positive}.


start(_Type, _Args) ->
    ?MODULE = ets:new(?MODULE, [named_table, ordered_set, public]),
    IdConstraints = { id, [int, fun positive_fun/2] },

    IdRoute = {"/results/:id",
                 [IdConstraints],
                 hello_handler,
                 []
              }, %The last arg becomes the State
                 %arg in the id_handler's init() method.

    CatchallRoute = {"/[...]", no_matching_route_handler, []},

    Dispatch = cowboy_router:compile([
        {"mail-testing.com", [
	       %{"/", cowboy_static, {priv_file, event_single, "index.html"}},
		{"/", cowboy_dyn, []},
	       {"/eventsource", eventsource_h, []},
	       IdRoute,
	       CatchallRoute
	]}
    ]),

    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 80}],
        #{env => #{dispatch => Dispatch} }
    ),

    event_single_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(http).


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
    <<X:64/big-unsigned-integer>> = crypto:strong_rand_bytes(8),
    _Random = lists:flatten(io_lib:format("~16.16.0b", [X])), %32=field width, Pad de zero, b est le Mod
    %Target = _Random++"@mail-testing.com",
    Target = list_to_binary(_Random++"@mail-testing.com"),
    io:format("event_single_app Random ~p ~n",[Target]),
    
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
		{"/", cowboy_dyn, [Target]},
	       {"/eventsource", eventsource_h, [Target]},
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


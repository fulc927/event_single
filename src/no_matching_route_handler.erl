-module(no_matching_route_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) -> %State comes from last argument of the route
    Req = cowboy_req:reply(404,
        #{<<"content-type">> => <<"text/plain">>},
        <<"[ME] 404. Whoops! (No matching route!)">>,
        Req0),
    {ok, Req, State}.

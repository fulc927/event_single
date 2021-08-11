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
    %le nom de la table servant a transférer les couples ip/ports est event_single_app ?MODULE
    ?MODULE = ets:new(?MODULE, [named_table, ordered_set, public]),
    ets:new(event_single_app2, [named_table, ordered_set, public]),

    IdConstraints = { id, [int, fun positive_fun/2] },
    IdRoute =   {"/results/:id",
                 [IdConstraints],
                 results_handler,
                 []
                },
   		 %The last arg becomes the State arg in the id_handler's init() method.

    %CatchallRoute = {"/[...]", no_matching_route_handler, []},
    CatchallRoute = {"/[...]", cowboy_static, {priv_file, event_single, "404.html"}},

  %  Dispatch_80 = cowboy_router:compile([
  %      {"mail-testing.com", [
  %      {"/", welcome_page, []},
  %      {"/eventsource", eventsource_h, []},
        %{"/home", cowboy_static, {priv_file, event_single, "home.html"}},
	     %   %IdRoute,
  %	        CatchallRoute
%	]}
  %  ]),

    Dispatch_443 = cowboy_router:compile([
        {"mail-testing.com", [
		{"/", welcome_page, []},
	        {"/eventsource", eventsource_h, []},
	        {"/home", cowboy_static, {priv_file, event_single, "home.html"}},
	        IdRoute,
	        CatchallRoute
	]}
    ]),

    {ok, _} = cowboy:start_tls(my_https_listener,
    %{ok, _} = cowboy:start_clear(my_http_listener,
        
 	[{port, 443},
        {certfile, "/etc/letsencrypt/live/mail-testing.com/fullchain.pem"},
        {keyfile, "/etc/letsencrypt/live/mail-testing.com/privkey.pem"}], 
				 
%	[{port, 80}],
        #{env => #{dispatch => Dispatch_443} }
    ),
    %%%EXPERIMENTAL
  %  {ok, _} = cowboy:start_clear(my_http_listener,
  %      
%	[{port, 80}],
%        #{env => #{dispatch => Dispatch_80} }
%    ),


    event_single_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(http).


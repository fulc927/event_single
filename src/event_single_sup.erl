-module(event_single_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Declarations2 = application:get_env(event_single, publish_declarations),
        {_, Dcls2} = Declarations2,

    Procs = [
	 #{id => my_publisher,
	   start => {turtle_publisher , 
		     start_link ,[my_publisher,amqp_server,Dcls2,
		     #{confirms => false}]},
           restart => permanent,
	   shutdown => 5000,
	   type => worker,
           module => [turtle_publisher]},
	 #{id => frequency_server,
           start =>  {frequency, start_link, []},
	   restart =>  permanent,
	   shutdown => 10000,
	   type =>  worker,
	   module => [frequency]},
	 #{id => store_and_dispatch_server,
           start =>  {store_and_dispatch, start_link, []},
	   restart =>  permanent,
	   shutdown => 10000,
	   type =>  worker,
	   module => [store_and_dispatch]} ],
	{ok, {{rest_for_one, 1, 5}, Procs}}.

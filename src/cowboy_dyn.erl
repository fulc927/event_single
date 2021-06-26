-module(cowboy_dyn).
-behavior(cowboy_handler).

-export([init/2]).
%-export([info/3]).

init(Req0, State) ->
	
	%%#{peer := IdCouple} = Req0,
	%%io:format("cowboy_dyn Req0 ~p ~n",[IdCouple]),
  	<<X:64/big-unsigned-integer>> = crypto:strong_rand_bytes(8),
        _Random = lists:flatten(io_lib:format("~16.16.0b", [X])), %32=field width, Pad de zero, b est le Mod
        Target = list_to_binary(_Random++"@mail-testing.com"),
        io:format("cowboy_dyn le email en random ~p ~n",[Target]),

        D = gen_server:cast(store_and_dispatch, {randomstring,{{82,64,230,35},53712},Target}),
	io:format("cowboy_dyn store ~p ~n",[D]),
        E = gen_server:call(store_and_dispatch, {query,{{82,64,230,35},53712}}), 
	io:format("cowboy_dyn lookup ~p ~n",[E]),


        %_D = gen_server:call(store_and_dispatch, {query,{{82,64,230,35},53712}}), 
	
	%gproc:reg({p, l, cowboy_dyn}),

	%Req = cowboy_req:reply(200,
	%cowboy_req:stream_body(["<html><head><title>","Hello world!","</title><script>",Script,"</script></head>","<body><p>",Body,"<div id=\"status\"></div>",State,"</p></body></html>"], nofin, Req0),
	
	Script = "<script>function ready() {if (!!window.EventSource) { setupEventSource(); } else { document.getElementById(\"status\").innerHTML = \"Sorry but your browser doesn t support the EventSource API\"; } } function setupEventSource() { var source = new EventSource(\"/eventsource\"); source.addEventListener('message', function(event) { addStatus(event.data); Y = event.data; console.log(Y); }, false); source.addEventListener(\"open\", function(event) { }, false); source.addEventListener(\"error\", function(event) { console.log(Y); location.replace(\"http://mail-testing.com/results/\" + Y); if (event.eventPhase == EventSource.CLOSED) { } }, false); } function addStatus(text) { document.getElementById(\"status\").innerHTML=text + \" secs\"; }</script>",
	Req = cowboy_req:stream_reply(200, #{<<"content-type">> => <<"text/html">>}, Req0),
	timer:sleep(1000),
	cowboy_req:stream_body([
			      
"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
   \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html lang=\"en-us\" xmlns=\"http://www.w3.org/1999/xhtml\">

    <head>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <link rel=\"icon\" href=\"data:;base64,iVBORw0KGgo=\" />
    <link rel=\"alternate\" type=\"application/rss+xml\" href=\"http://mail-testing.com/index.xml\" title=\"Accessible Minimalism\" />
    
    
    <title>Accessible Minimalism</title>",
 Script,

    "<style type=\"text/css\">
     body {
     font-size: 150%;
     font-family: muli,avenir,helvetica neue,helvetica,ubuntu,roboto,noto,segoe ui,arial,sans-serif;
     }
    </style>

    </head>

<body onload=\"ready()\">
    <div style=\"overflow: hidden;\">
  <!-- <p style=\"float: left;\"><a href=\"#nav-menu\">Menu</a></p> 
  <p style=\"float: right;\"><a\"><strong>Menu du site</strong></a></p> -->
<ul style=\"float: right;\">
    <li> 
      <a href=\"/\">
      Home
      </a>
    </li>
    
    <li>
      <a href=\"/posts/\">
      </a>
    </li>
</ul>
</div>

  <h1 style=\"text-align:center\">Mail-testing</h1>

  <div> <p style=\"text-align:center\">",Target,"<div style=\"text-align:center\" id=\"status\"></div></p>
<p><a href=\"#\">Back to top</a></p>
</body>

</html>"



			       
			       
			       ], fin,
			       Req),

    {ok, Req, State}.

%info({reply, Body}, Req, State) ->
%	    cowboy_req:reply(200, #{}, Body, Req),
%	        {stop, Req, State};
%info(_Msg, Req, State) ->
%	    {ok, Req, State, hibernate}.


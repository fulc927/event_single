-module(cowboy_dyn).
-behavior(cowboy_handler).

-export([init/2]).
%-export([info/3]).

init(Req0, State) ->
	%gproc:reg({p, l, cowboy_dyn}),

	%Req = cowboy_req:reply(200,
	%cowboy_req:stream_body(["<html><head><title>","Hello world!","</title><script>",Script,"</script></head>","<body><p>",Body,"<div id=\"status\"></div>",State,"</p></body></html>"], nofin, Req0),
	
	Req = cowboy_req:stream_reply(200, #{<<"content-type">> => <<"text/html">>}, Req0),
	timer:sleep(1000),
	cowboy_req:stream_body("<html><head><title>mail-testing</title><script>function ready() {if (!!window.EventSource) { setupEventSource(); } else { document.getElementById(\"status\").innerHTML = \"Sorry but your browser doesn t support the EventSource API\"; } } function setupEventSource() { var source = new EventSource(\"/eventsource\"); source.addEventListener('message', function(event) { addStatus(event.data); Y = event.data; console.log(Y); }, false); source.addEventListener(\"open\", function(event) { }, false); source.addEventListener(\"error\", function(event) { console.log(Y); location.replace(\"http://mail-testing.com/results/\" + Y); if (event.eventPhase == EventSource.CLOSED) { } }, false); } function addStatus(text) { document.getElementById(\"status\").innerHTML=text + \" secs\"; }</script></head><body onload=\"ready()\"><p>salut<div id=\"status\"></div></p></body></html>", fin, Req),

    {ok, Req, State}.

%info({reply, Body}, Req, State) ->
%	    cowboy_req:reply(200, #{}, Body, Req),
%	        {stop, Req, State};
%info(_Msg, Req, State) ->
%	    {ok, Req, State, hibernate}.

-module(cowboy_dyn).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
	io:format("cowboy_dyn State ~p ~n",[State]),
	%Random = <<"test@test">>,
        Body =  "<button onclick=\"ready()\">Start</button> Press the \"Start\" to begin.<button onclick=\"stop()\">Stop</button> \"Stop\" to finish. Hi! Pour tester votre email, vous devez envoyer un message a l'adresse ci-dessous: ",
        %Body =  "<button onclick=\"ready()\">Start</button> Press the \"Start\" to begin.<button onclick=\"stop()\">Stop</button> \"Stop\" to finish. Hi! Pour tester votre email, vous devez envoyer un message a l'adresse ci-dessous: <div id=\"status\"></div>",
	Script = "function ready() {if (!!window.EventSource) { setupEventSource(); } else { document.getElementById(\"status\").innerHTML = \"Sorry but your browser doesn t support the EventSource API\"; } } function setupEventSource() { var source = new EventSource(\"/eventsource\"); source.addEventListener('message', function(event) { addStatus(event.data); Y = event.data; console.log(Y); }, false); source.addEventListener(\"open\", function(event) { }, false); source.addEventListener(\"error\", function(event) { console.log(Y); location.replace(\"http://mail-testing.com/results/\" + Y); if (event.eventPhase == EventSource.CLOSED) { } }, false); } function addStatus(text) { document.getElementById(\"status\").innerHTML=text + \" secs\"; }",
%	Script = "function ShowMessage() {alert(\"Hello World!\");}" ,
	Req = cowboy_req:reply(200,
    		#{<<"content-type">> => <<"text/html">>},
		 ["<html><head><title>","Hello world!","</title><script>",Script,"</script></head>","<body><p>",Body,"<div id=\"status\"></div>",State,"</p></body></html>"], 
		Req0),
    {ok, Req, State}.

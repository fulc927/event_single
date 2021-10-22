-module(welcome_page).
-behavior(cowboy_handler).
-include_lib("kernel/include/inet.hrl").
-export([init/2,test/1]).
%-export([info/3]).

init(Req0, State) ->
	
	%enregistrement du couple IP/NAT du navigateur client
	%welcome_page Req0 {{93,22,148,15},52793}
	#{peer := IdCouple} = Req0,
	io:format("welcome_page #peer IdCouple ~p ~n",[IdCouple]),
	io:format("welcome_page Req ~p ~n",[Req0]),
	{{A,_B,_C,_D,_E,_F,_G,_H}=Touc,_} =  IdCouple,
	io:format("welcome_page Touc ~p ~n",[Touc]),
	Touc4 = inet:ipv4_mapped_ipv6_address(Touc),
	io:format("welcome_page Touc4 ~p ~n",[Touc4]),

	{ok, Image} = test(A),
	io:format("welcome_page Image ~p ~n",[Image]),

	%CrÃ©ation de l'adresse random
  	<<X:64/big-unsigned-integer>> = crypto:strong_rand_bytes(8),
        _Random = lists:flatten(io_lib:format("~16.16.0b", [X])), %32=field width, Pad de zero, b est le Mod
        Target = list_to_binary(_Random++"@mail-testing.com"),
        io:format("welcome_page le email en random ~p ~n",[Target]),

	%opÃ©rations ETS
        %E = gen_server:call(store_and_dispatch, {query,IdCouple}), 
	%io:format("welcome_page LOOKUP ETS renvoi qqlchose en cas de reload intempestif  ~p ~n",[E]),
        gen_server:cast(store_and_dispatch, {insert,IdCouple,Target}),
	io:format("welcome_page Insert ip and port du navigateur  ~p ~p ~n",[IdCouple,Target]),

	%Script JAVASCRIPT pour le WSS
	Script = "<script>function ready() {if (!!window.EventSource) { setupEventSource(); } else { document.getElementById(\"status\").innerHTML = \"Sorry but your browser doesn t support the EventSource API\"; } } function setupEventSource() { var source = new EventSource(\"/eventsource\"); source.addEventListener('message', function(event) { addStatus(event.data); Y = event.data; console.log(Y); }, false); source.addEventListener(\"open\", function(event) { }, false); source.addEventListener(\"error\", function(event) { console.log(Y); location.replace(\"https://mail-testing.com/results/\" + Y); if (event.eventPhase == EventSource.CLOSED) { } }, false); } function addStatus(text) { document.getElementById(\"status\").innerHTML=text + \" secs\"; }</script>",
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
    <link rel=\"alternate\" type=\"application/rss+xml\" href=\"https://mail-testing.com/index.xml\" title=\"Mail-testing\" />
    <title>Mail-testing</title>",
    Script,
 % CSS
    "<style type=\"text/css\">
     body {
     font-size: 150%;
     font-family: muli,avenir,helvetica neue,helvetica,ubuntu,roboto,noto,segoe ui,arial,sans-serif;
     }
    </style>
    </head>

    <!-- <body onload=\"ready();\">  -->
    <body>
	<div style=\"position:relative;\">
  	<h1 style=\"text-align:center\">Mail-testing</h1>
 	<div style=\"text-align:center\">",Target,"</div>
	<div style=\"text-align:center\"><button onclick=\"ready();\"> Lancer le test </button> </div>
  	<div style=\"text-align:center\" id=\"status\"></div>


  	<div style=\"position:absolute;right:0;top:0\">
    		<ul>
      			<li> 
        			<a href=\"/\">
        			Home
        			</a>
      			</li>
    
      			<li>
        			<a href=\"/home/\">
        			About
        			</a>
      			</li>
    		</ul>
  	</div>
 	
	<!-- <div style=\"position:absolute;left:0;top:0\">   <img src=\"/home/img/rabb.png\" alt=\"Girl in a jacket\"> </div> -->

	</div>
        </br>
	<!-- <div style=\"text-align:center\"> <img src=",Image," alt=\"Girl in a jacket\"> </div>  -->
	     <div style=\"position:absolute;left:0;top:0\">   <img src=",Image," alt=\"Girl in a jacket\"> </div>



</body>

</html>"
			       
			       ], fin,
			       Req),

    {ok, Req, State}.

%{{_A,_B,_C,_D,_E,_F,_G,_H}=Touc,_} =  IdCouple,
%	io:format("welcome_page Touc ~p ~n",[Touc]),
%	Touc4 = inet:ipv4_mapped_ipv6_address(Touc),
%	io:format("welcome_page Touc4 ~p ~n",[Touc4]),
test(A) ->
        Image = case A of
		        0 ->
				io:format("welcome_handler CAS IPV4 ~n"),
				"/home/img/rabb.png";
			_ ->
				io:format("welcome_hadler CAS IPV6 ~n"),
				"/home/img/rabb_move.gif"
		    	end,
{ok, Image}.

%info({reply, Body}, Req, State) ->
%	    cowboy_req:reply(200, #{}, Body, Req),
%	        {stop, Req, State};
%info(_Msg, Req, State) ->
%	    {ok, Req, State, hibernate}.


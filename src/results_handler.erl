-module(results_handler).
-behavior(cowboy_handler).
-export([init/2]).
-export([info/3]).
-record( state, { sender_pid,booked_queue}).

init(Req, _State) ->
	%#{peer := IdCouple} = Req,
	%io:format("results_handler #peer IdCouple ~p ~n",[IdCouple]),
	%io:format("results_handler #peer Req ~p ~n",[Req]),

	%%NINENINES access a value bound from the route
	Id = cowboy_req:binding(id, Req),
	io:format("results_handler init Id de cowboy ~p ~n",[Id]),
	
	%results_handler Id 12213958
	Self = self(),
	
        %E = gen_server:call(store_and_dispatch, {query2,IdCouple}), 
	%io:format("results_handler le E il se cache ou ? ~p ~n",[E]),

	%TEST1
	{_,QBook} = test1(Id,Self),
	%io:format("results_handler test1 Vuck ~p ~n",[Vuck]),
	%io:format("results_handler E IdCouple from ets store_and_dispatch ~p ~n",[E]),
	%io:format("result_handlers Id QBook IdCouple ~p ~p ~p ~n",[Id,Vuck,IdCouple]),

 	%{ok, QBook} = gen_server:call(queuedistrib, {allocate2, Self}),

	%TEST2
	{_,SenderPid} = test2(Id,QBook),
        %{ok, SenderPid} = gen_consume_results:start({Id,QBook}),

	io:format("results_handler QBook ~p ~n",[QBook]),
	io:format("results_handler init STATE ~p ~n",[_State]),
	%on register avec le binding qui vient du httpc call
	io:format("results_handler init GPROC ~p ~n",[Id]),

	%% DOUBLE REGISTRATION LOOP AMQP
        gproc:reg({p, l, Id}),
        gproc:reg({p, l, amqphijack}),

    State2 = #state{sender_pid=SenderPid,booked_queue=QBook},
    {cowboy_loop, Req, State2,hibernate}.


test1(Id,Self) ->
        Val1 = case Id of
		        59  ->
				io:format("results_handler BADSTART ~n"),
				[];
			58  ->
				io:format("results_handler BADSTART ~n"),
				[];
			57  ->
				io:format("results_handler BADSTART ~n"),
				[];
			56  ->
				io:format("results_handler BADSTART ~n"),
				[];
			55  ->
				io:format("results_handler BADSTART ~n"),
				[];
			54  ->
				io:format("results_handler BADSTART ~n"),
				[];
			53  ->
				io:format("results_handler BADSTART ~n"),
				[];
			52  ->
				io:format("results_handler BADSTART ~n"),
				[];
			51  ->
				io:format("results_handler BADSTART ~n"),
				[];
			50  ->
				io:format("results_handler BADSTART ~n"),
				[];
			49  ->
				io:format("results_handler BADSTART ~n"),
				[];
			48  ->
				io:format("results_handler BADSTART ~n"),
				[];
			47  ->
				io:format("results_handler BADSTART ~n"),
				[];
			46  ->
				io:format("results_handler BADSTART ~n"),
				[];
			45  ->
				io:format("results_handler BADSTART ~n"),
				[];
			44  ->
				io:format("results_handler BADSTART ~n"),
				[];
			43  ->
				io:format("results_handler BADSTART ~n"),
				[];
			42  ->
				io:format("results_handler BADSTART ~n"),
				[];
			41  ->
				io:format("results_handler BADSTART ~n"),
				[];
			40  ->
				io:format("results_handler BADSTART ~n"),
				[];
			39  ->
				io:format("results_handler BADSTART ~n"),
				[];
			38  ->
				io:format("results_handler BADSTART ~n"),
				[];
			37  ->
				io:format("results_handler BADSTART ~n"),
				[];
			36  ->
				io:format("results_handler BADSTART ~n"),
				[];
			35  ->
				io:format("results_handler BADSTART ~n"),
				[];
			34  ->
				io:format("results_handler BADSTART ~n"),
				[];
			33  ->
				io:format("results_handler BADSTART ~n"),
				[];
			32  ->
				io:format("results_handler BADSTART ~n"),
				[];
			31  ->
				io:format("results_handler BADSTART ~n"),
				[];
			30  ->
				io:format("results_handler BADSTART ~n"),
				[];
			29  ->
				io:format("results_handler BADSTART ~n"),
				[];
			28  ->
				io:format("results_handler BADSTART ~n"),
				[];
			27  ->
				io:format("results_handler BADSTART ~n"),
				[];
			26  ->
				io:format("results_handler BADSTART ~n"),
				[];
			25  ->
				io:format("results_handler BADSTART ~n"),
				[];
			24  ->
				io:format("results_handler BADSTART ~n"),
				[];
			23  ->
				io:format("results_handler BADSTART ~n"),
				[];
			22  ->
				io:format("results_handler BADSTART ~n"),
				[];
			21  ->
				io:format("results_handler BADSTART ~n"),
				[];
			20  ->
				io:format("results_handler BADSTART ~n"),
				[];
			19  ->
				io:format("results_handler BADSTART ~n"),
				[];
			18  ->
				io:format("results_handler BADSTART ~n"),
				[];
			17  ->
				io:format("results_handler BADSTART ~n"),
				[];
			16  ->
				io:format("results_handler BADSTART ~n"),
				[];
			15  ->
				io:format("results_handler BADSTART ~n"),
				[];
			14  ->
				io:format("results_handler BADSTART ~n"),
				[];
			13  ->
				io:format("results_handler BADSTART ~n"),
				[];
			12  ->
				io:format("results_handler BADSTART ~n"),
				[];
			11  ->
				io:format("results_handler BADSTART ~n"),
				[];
			10  ->
				io:format("results_handler BADSTART ~n"),
				[];
			9  ->
				io:format("results_handler BADSTART ~n"),
				[];
			8  ->
				io:format("results_handler BADSTART ~n"),
				[];
			7  ->
				io:format("results_handler BADSTART ~n"),
				[];
			6  ->
				io:format("results_handler BADSTART ~n"),
				[];
			5  ->
				io:format("results_handler BADSTART ~n"),
				[];
			4  ->
				io:format("results_handler BADSTART ~n"),
				[];
			3  ->
				io:format("results_handler BADSTART ~n"),
				[];
			2  ->
				io:format("results_handler BADSTART ~n"),
				[];
			1  ->
				io:format("results_handler BADSTART ~n"),
				[];
			0  ->
				io:format("results_handler BADSTART ~n"),
				[];
_ ->
				io:format("test1 processus normal affectation d’une QUEUE random ~n"),
        			{ok, QBook} = gen_server:call(queuedistrib, {allocate2, Self}),
				QBook
		    	end,
  {ok, Val1}.


test2(Id,QBook) ->
        Val2 = case QBook of
		        [] ->
				io:format("results_handler Id quand ça BADSTART ~p ~n",[Id]),
%        			gen_server:cast(store_and_dispatch, {insert,IdCouple,[]}),
        			{ok, SenderPid} = gen_consume_amqphijack:start_link(),
				SenderPid;
			_ ->
%				io:format("results_handler E IdCouple est bien la ~p ~n",[E]),
        			{ok, SenderPid} = gen_consume_results:start({Id,QBook}),
				SenderPid
		    	end,
  {ok, Val2}.

%info({results_page, Dkim, Date, Ip, Serveur,Spf_pass,Dkim_valid,Payload}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook,idcouple=IdCouple}=State) ->
info({results_page, Dkim, Date, Ip, Serveur,Spf2_pass,Spf_pass,Dkim_valid,Payload}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->
	io:format("results_handler LA PAGE HTML S AFFICHE ! ~n"),
        gen_server:cast(queuedistrib,{deallocate2, _QBook}),
	io:format("results_handler QBook2 deallocate2 ! ~n"),
	io:format("results_handler INSIDE PAGE HTML Spf_pass ~p ~n",[Spf_pass]),
	io:format("results_handler INSIDE PAGE HTML Spf2_pass ~p ~n",[Spf2_pass]),
	io:format("results_handler INSIDE PAGE HTML Serveur ~p ~n",[Serveur]),
	io:format("results_handler INSIDE PAGE HTML Dkim_valid ~p ~n",[Dkim_valid]),
	_Title = "le titre",
	%Body = "le body",
        cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, 
			 
[
"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
   \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html lang=\"en-us\" xmlns=\"http://www.w3.org/1999/xhtml\">

    <head>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <link rel=\"icon\" href=\"data:;base64,iVBORw0KGgo=\" />
    <link rel=\"alternate\" type=\"application/rss+xml\" href=\"https://mail-testing.com/index.xml\" title=\"Mail-testing\" />
    
    
    <title>Mail-testing</title>
    <style type=\"text/css\">
        .emojify {
	font-family: Apple Color Emoji, Segoe UI Emoji, NotoColorEmoji, Segoe UI Symbol, Android Emoji, EmojiSymbols;
	font-size: 2rem;
	vertical-align: middle;
	}

	@media screen and (max-width:650px) {
  	.nowrap {
    	display: block;
    	margin: 25px 0;
  	}
	}
        pre {
    	white-space: pre-wrap;       /* Since CSS 2.1 */
    	white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
    	white-space: -pre-wrap;      /* Opera 4-6 */
    	white-space: -o-pre-wrap;    /* Opera 7 */
    	word-wrap: break-word;       /* Internet Explorer 5.5+ */
	} 
	body {
    	font-size: 150%; 
    	font-family: muli,avenir,helvetica neue,helvetica,ubuntu,roboto,noto,segoe ui,arial,sans-serif;
     	}
	#cont {display: none; }
           .show:focus + .hide {display: inline; }
           .show:focus + .hide + #cont {display: block;}
    </style>

    </head>

<body>

<div style=\"overflow: hidden;\">
  <p style=\"float: left;\"><a href=\"https://mail-testing.com\"><=Mail-testing</a></p>
<ul style=\"float: right;\">
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

 <h1 style=\"text-align:center\">Resultats</h1>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Date,"</pre>

<div> <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#hide\"class=\"hide\">[Hide]</a> 
        <div id=\"cont\">lopsum ui i niusrtan i au mnsrt n nstns sd nsrtnn t nt nstnstnan naursitnaietaunrietan rt ng gg gpa gaugepébg biuuinuisnuinuain ii nrsuainnanauinuaiua ii n strnnstrnstrrnstnrtsnrts</div> </div>
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">Le SPF ",Spf_pass,"</pre>

	<div> <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#hide\"class=\"hide\">[Hide]</a> 
        <div id=\"cont\">lopsum ui i niusrtan i au mnsrt n nstns sd nsrtnn t nt nstnstnan naursitnaietaunrietan rt ng gg gpa gaugepébg biuuinuisnuinuain ii nrsuainnanauinuaiua ii n strnnstrnstrrnstnrtsnrts</div> </div>
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">Le SPF2 ",Spf2_pass,"</pre>


<div> <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#hide\"class=\"hide\">[Hide]</a> 
        <div id=\"cont\">lopsum ui i niusrtan i au mnsrt n nstns sd nsrtnn t nt nstnstnan naursitnaietaunrietan rt ng gg gpa gaugepébg biuuinuisnuinuain ii nrsuainnanauinuaiua ii n strnnstrnstrrnstnrtsnrts</div> </div>
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">L adresse IP ",Ip,"</pre>

<div> <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#hide\"class=\"hide\">[Hide]</a> 
        <div id=\"cont\">lopsum ui i niusrtan i au mnsrt n nstns sd nsrtnn t nt nstnstnan naursitnaietaunrietan rt ng gg gpa gaugepébg biuuinuisnuinuain ii nrsuainnanauinuaiua ii n strnnstrnstrrnstnrtsnrts</div> </div>
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">Le serveur ",Serveur,"</pre>

<div> <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#hide\"class=\"hide\">[Hide]</a> 
        <div id=\"cont\">lopsum ui i niusrtan i au mnsrt n nstns sd nsrtnn t nt nstnstnan naursitnaietaunrietan rt ng gg gpa gaugepébg biuuinuisnuinuain ii nrsuainnanauinuaiua ii n strnnstrnstrrnstnrtsnrts</div> </div>
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Dkim_valid,"</pre>

<div> <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;font-size: 75%;color: orange;\" href=\"#hide\"class=\"hide\">[Hide]</a> 
        <div id=\"cont\">lopsum ui i niusrtan i au mnsrt n nstns sd nsrtnn t nt nstnstnan naursitnaietaunrietan rt ng gg gpa gaugepébg biuuinuisnuinuain ii nrsuainnanauinuaiua ii n strnnstrnstrrnstnrtsnrts</div> </div>
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Dkim,"</pre>


<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Payload,"</pre>

<p><a href=\"#\">Back to top</a></p>


</body>

</html>"
],
			 Req),

	  %  cowboy_req:reply(200, #{}, Body, Req),
	
	%%%DELETE du putain de port HTTPS
        %gen_server:cast(store_and_dispatch, {delete,IdCouple}), 
       	%Eau = gen_server:call(store_and_dispatch, {query,IdCouple}), 
	%io:format("results_handler VRAIMENT SUPPRIME ? ~p ~n",[Eau]),
	%%%DELETE 

	gen_server:stop(SenderPid),
	        {stop, Req, State};

%info({results_null, []}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook,idcouple=IdCouple}=State) ->
info({results_null, []}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->

	io:format("results_handler PAGE NULL sAFFICHE ! ~n"),
        %gen_server:cast(queuedistrib,{deallocate2, _QBook}),
	_Title = "le titre",
	Message_null = "Aucun message intercepte",
        cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, 
		
%	["<html><head><title>Hello world!</title><script></script></head><body><p><div>page internet hop</div></p></body></html>"]
			 %	,Req),


[
"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
   \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html lang=\"en-us\" xmlns=\"http://www.w3.org/1999/xhtml\">

    <head>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <link rel=\"icon\" href=\"data:;base64,iVBORw0KGgo=\" />
    <link rel=\"alternate\" type=\"application/rss+xml\" href=\"https://mail-testing.com/index.xml\" title=\"Mail-testing\" />
    
    
    <title>Mail-testing</title>
    <style type=\"text/css\">
        .emojify {
	font-family: Apple Color Emoji, Segoe UI Emoji, NotoColorEmoji, Segoe UI Symbol, Android Emoji, EmojiSymbols;
	font-size: 2rem;
	vertical-align: middle;
	}

	@media screen and (max-width:650px) {
  	.nowrap {
    	display: block;
    	margin: 25px 0;
  	}
	}
        pre {
    	white-space: pre-wrap;       /* Since CSS 2.1 */
    	white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
    	white-space: -pre-wrap;      /* Opera 4-6 */
    	white-space: -o-pre-wrap;    /* Opera 7 */
    	word-wrap: break-word;       /* Internet Explorer 5.5+ */
	} 
	body {
    	font-size: 150%; 
    	font-family: muli,avenir,helvetica neue,helvetica,ubuntu,roboto,noto,segoe ui,arial,sans-serif;
     	}
	#cont {display: none; }
           .show:focus + .hide {display: inline; }
           .show:focus + .hide + #cont {display: block;}
    </style>

    </head>

<body>

<div style=\"overflow: hidden;\">
  <p style=\"float: left;\"><a href=\"https://mail-testing.com\">Back</a></p>
<ul style=\"float: right;\">
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
<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Message_null,"</pre>

<p><a href=\"#\">Back to top</a></p>


</body>

</html>"
],Req),

	%%%DELETE du putain de port HTTPS
        %gen_server:cast(store_and_dispatch, {delete,IdCouple}), 
       	%Eau = gen_server:call(store_and_dispatch, {query,IdCouple}), 
	%io:format("results_handler VRAIMENT SUPPRIME ? ~p ~n",[Eau]),
	%%%DELETE 

	gen_server:stop(SenderPid),
	        {stop, Req, State};


info(_Msg, Req, State) ->
	    {ok, Req, State, hibernate}.

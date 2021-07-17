-module(results_handler).
-behavior(cowboy_handler).
-export([init/2]).
-export([info/3]).
-record( state, { sender_pid,booked_queue}).

init(Req, _State) ->
	%welcome_page Req0 {{93,22,148,15},52793}
	#{peer := IdCouple} = Req,
	io:format("result_handlers IdCouple ~p ~n",[IdCouple]),

	Id = cowboy_req:binding(id, Req),
	io:format("result_handlers Id ~p ~n",[Id]),
	%results_handler Id 12213958
	Self = self(),
        {ok, QBook} = gen_server:call(frequency, {allocate2, Self}),
        {ok, _SenderPid} = gen_consume_results:start({Id,QBook,IdCouple}),
        E = gen_server:call(store_and_dispatch, {query,IdCouple}), 
	io:format("results_handler IdCouple from ets store_and_dispatch ~p ~n",[E]),

	%%faire un case la
	case E of
		    [] ->
				io:format("results_handler Case1 ~p ~n",[E]);
		    _ ->
				io:format("results_handler Case2 ~p ~n",[E])
	end,

	io:format("results_handler QBook2 ~p ~n",[QBook]),
	io:format("results_handler init STATE ~p ~n",[_State]),
	%on register avec le binding qui vient du httpc call
        gproc:reg({p, l, Id}),
    State2 = #state{sender_pid=_SenderPid,booked_queue=QBook},
    {cowboy_loop, Req, State2,hibernate}.

info({results_page, Dkim, Date, Ip, Serveur,Dkim_valid,Payload}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->
	io:format("results_handler LA PAGE HTML S AFFICHE ! ~n"),
        gen_server:cast(frequency,{deallocate2, _QBook}),
	io:format("results_handler QBook2 deallocate2 ! ~n"),
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
    <link rel=\"alternate\" type=\"application/rss+xml\" href=\"http://mail-testing.com/index.xml\" title=\"Accessible Minimalism\" />
    
    
    <title>Accessible Minimalism</title>
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
  <p style=\"float: left;\"><a href=\"http://mail-testing.com\"><=Mail-testing</a></p>
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
 <li>
      <a href=\"/home/\">
      About
      </a>
    </li>
</ul>
</div>

 <h1 style=\"text-align:center\">Results</h1>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Date,"</pre>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Ip,"</pre>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Serveur,"</pre>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Dkim_valid,"</pre>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Dkim,"</pre>
	<div> <a style=\"float: right;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;\" href=\"#hide\"class=\"hide\">[Hide]</a>
        <div id=\"cont\">Content uiestaunre auinetau tuins t ausnetaunr t tunsetaunrestaun tn ausrnteanute t  tsrntenauiet tn  nrusteanr tarnet narut  netaunrs etaurnet n nrest t  t     srnetaunretanuet      anretaunretanuetan t</div>  </div>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Payload,"</pre>

<p><a href=\"#\">Back to top</a></p>


</body>

</html>"
],
			 Req),

	  %  cowboy_req:reply(200, #{}, Body, Req),
	gen_server:stop(SenderPid),
	        {stop, Req, State};

info({results_null, []}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->

	io:format("results_handler PAGE NULL sAFFICHE ! ~n"),
        gen_server:cast(frequency,{deallocate2, _QBook}),
	_Title = "le titre",
	Message_null = "Aucun message intercepté",
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
    <link rel=\"alternate\" type=\"application/rss+xml\" href=\"http://mail-testing.com/index.xml\" title=\"Accessible Minimalism\" />
    
    
    <title>Accessible Minimalism</title>
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
  <p style=\"float: left;\"><a href=\"http://mail-testing.com\">Back</a></p>
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


	gen_server:stop(SenderPid),
	        {stop, Req, State};


info(_Msg, Req, State) ->
	    {ok, Req, State, hibernate}.

-module(hello_handler).
-behavior(cowboy_handler).
-export([init/2]).
-export([info/3]).
-record( state, { sender_pid,booked_queue}).

init(Req, _State) ->
	Id = cowboy_req:binding(id, Req),
	Self = self(),
        {ok, QBook} = gen_server:call(frequency, {allocate, Self}),
        {ok, _SenderPid} = gen_consume_score:start({Id,QBook}),
	io:format("gen_consume_score QBook ~p ~n",[QBook]),
	io:format("hello_handler init STATE ~p ~n",[_State]),
       gproc:reg({p, l, Id}),
    State2 = #state{sender_pid=_SenderPid,booked_queue=QBook},
    {cowboy_loop, Req, State2,hibernate}.

info({message2, Date, Dkim,_Dkim_valid}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->
	io:format("hello_handler INFO/3 Hop ~p ~n",[Dkim]),
	%io:format("hello_handler INFO/3 Req ~p ~n",[Req]),
	io:format("hello_handler LA PAGE HTML S AFFICHE ! ~n"),
        gen_server:cast(frequency,{deallocate, _QBook}),

	_Title = "le titre",
	Ipv6 = "l adresse ipv6",
	%Body = "le body",
        cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, 
			 
			 
%			       ["<html><head><title>", Title, "</title></head>","<body><p>", Body, "</p></body></html>"],
			 
	
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
      <a href=\"/posts/\">
      </a>
    </li>
</ul>
</div>

 <h1 style=\"text-align:center\">Results</h1>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Date,"</pre>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Ipv6,"</pre>

<pre style=\"width:100%;color:#f8f8f2;background-color:#272822\">",Dkim,"</pre>
	<div> <a style=\"float: right;\" href=\"#show\"class=\"show\">[Show]</a>
              <a style=\"float: right;\" href=\"#hide\"class=\"hide\">[Hide]</a>
        <div id=\"cont\">Content uiestaunre auinetau tuins t ausnetaunr t tunsetaunrestaun tn ausrnteanute t  tsrntenauiet tn  nrusteanr tarnet narut  netaunrs etaurnet n nrest t  t     srnetaunretanuet      anretaunretanuetan t</div>  </div>

<p><a href=\"#\">Back to top</a></p>


</body>

</html>"
],

			 Req),

	  %  cowboy_req:reply(200, #{}, Body, Req),
	gen_server:stop(SenderPid),
	        {stop, Req, State};
info(_Msg, Req, State) ->
	    {ok, Req, State, hibernate}.

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

info({message2, Dkim}, Req, #state{sender_pid=SenderPid,booked_queue=_QBook}=State) ->
	io:format("hello_handler INFO/3 Hop ~p ~n",[Dkim]),
	%io:format("hello_handler INFO/3 Req ~p ~n",[Req]),
	io:format("hello_handler LA PAGE HTML S AFFICHE ! ~n"),
        gen_server:cast(frequency,{deallocate, _QBook}),

	_Title = "le titre",
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

	body {
    	font-size: 150%;
    	font-family: muli,avenir,helvetica neue,helvetica,ubuntu,roboto,noto,segoe ui,arial,sans-serif;
     	}
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


<div><pre style=\"color:#f8f8f2;background-color:#272822;-moz-tab-size:4;-o-tab-size:4;tab-size:4\"><code class=\"language-html\" data-lang=\"html\">",Dkim,"</code></pre></div>

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

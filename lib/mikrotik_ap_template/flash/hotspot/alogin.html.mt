$(if http-header == "Access-Control-Allow-Origin")*$(endif)
$(if http-header == "Access-Control-Allow-Methods")POST,GET,OPTIONS$(endif)
$(if http-header == "Access-Control-Allow-Headers")Origin$(endif)
<html>
  <head>
    <title>${title}</title>
    <!--meta http-equiv="refresh" content="0; url=$(if login-by != http-pap)$(link-login)$(else)$(link-redirect)$(endif)"-->
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="expires" content="-1">
    <style>
  		body {text-align: center;}
  		button {
  			border: 1px solid #ccc;
  			border-radius: 15px;
  			background: #eee;
  			text-transform: uppercase;
  			color: #333;
  			font-size: xx-large;
  			font-family: sans-serif;
  			margin-top: 20%;
  			cursor: pointer;
  			font-weight: normal;
  		}
  		nav a {color: #ccc;}
  		body {transition: all 3s linear;}
  		body.faded {background-color: #000;}
  		* { display: none;}
  	</style>
  </head>
  <body>
    <main>
      <form name="redirect" action="$(link-redirect)" method="GET">
        <div data-var="form_html">
        $(if login-by != http-pap)<input type="hidden" name="dst" value="$(link-orig)" />$(endif)
        </div>
        <button type="submit" class="main-button">Продолжить</button>
      </form>
      <script>
        <!--
        setTimeout(function() {document.redirect.submit();document.body.className = "faded";}, 50);
        -->
      </script>
    </main>
  </body>
</html>

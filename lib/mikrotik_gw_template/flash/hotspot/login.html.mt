$(if http-header == "Access-Control-Allow-Origin")*$(endif)
$(if http-header == "Access-Control-Allow-Methods")POST,GET,OPTIONS$(endif)
$(if http-header == "Access-Control-Allow-Headers")Origin$(endif)
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>${title}</title>
	<script src="platform.js"></script>
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
			display: none;
		}
		nav a {color: #ccc;}
		body {transition: all 3s linear;}
		body.faded {background-color: #000;}
		* { display: none;}
	</style>
</head>
<body>
	<nav><a href="en/login.html">English</a></nav>
	<main>
		<noscript><div class="warning">Для входа в Интернет, необходим JavaScript.</div></noscript>
		<form name="redirect" action="https://login.gycwifi.com/connecting" method="POST">
			<div data-var="form_html">
				<input type="hidden" name="mac" value="$(mac)" />
				<input type="hidden" name="ip" value="$(ip)" />
				<input type="hidden" name="username" value="$(if trial == yes)T-$(mac)$(else)$(username)$(endif)" />
				<input type="hidden" name="link-login" value="$(link-login)" />
				<input type="hidden" name="link-orig" value="$(link-orig)" />
				<input type="hidden" name="dst" value="$(link-orig)" />
				<input type="hidden" name="error" value="$(error)" />
				$(if chap-id)
				<input type="hidden" name="chap-id" value="$(chap-id)" />
				<input type="hidden" name="chap-challenge" value="$(chap-challenge)" />
				$(endif)
				<input type="hidden" name="link-login-only" value="$(link-login-only)" />
				<input type="hidden" name="link-orig-esc" value="$(link-orig-esc)" />
				<input type="hidden" name="trial" value="$(trial)" />
				<input type="hidden" name="mac-esc" value="$(mac-esc)" />
			</div>
			<input type="hidden" name="nas_cn" value="${common_name}" />
			<input type="hidden" name="nas_serial" value="${serial}" />
			<input type="hidden" name="iphone" value="" />
			<input type="hidden" name="platform_os" value="" />
			<input type="hidden" name="platform_product" value="" />
			<button type="submit" class="main-button">Продолжить</button>
		</form>
		<script>
			document.querySelector('input[name="platform_os"]').value = platform.os;
			document.querySelector('input[name="platform_product"]').value = platform.product;
			var get = location.search;
			if (get != '') {
				var params = get.substr(1).split('&');
				var param;
				for (var i = 0; i < params.length; i++) {
					param = params[i].split('=');
					if (param[0] == 'iphone') {
						document.querySelector('input[name="iphone"]').value = param[1];
						break;
					}
				}
			};
			setTimeout(function(){window.document.redirect.submit();}, 50);
		</script>
	</main>
</body>
</html>

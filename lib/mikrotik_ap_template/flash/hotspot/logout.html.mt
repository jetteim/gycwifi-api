<!DOCTYPE html>
$(if http-header == "Access-Control-Allow-Origin")*$(endif)
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title data-var="/brand.root_title">${title}</title>
	<meta http-equiv="pragma" content="no-cache" />
	<meta http-equiv="expires" content="-1" />
	<!--<link rel="stylesheet" data-when="/debug" href="common.css" />-->
	<style data-var="/common_css"></style>
	<style data-var="/css"></style>
</head>
<body>
<script language="JavaScript">
<!--
	function openLogin() {
		if (window.name != 'hotspot_logout') return true;
		open('$(link-login)', '_blank', '');
		window.close();
		return false;
	}
//-->
</script>

<main>

<h3>Выход успешен</h3>

<table class="tabula">
<tr><td>Номер билета</td><td>$(username)</td></tr>
<tr><td>IP адрес</td><td>$(ip)</td></tr>
<!--<tr><td>MAC адрес</td><td>$(mac)</td></tr>-->
<tr><td>Входящий траффик:</td><td>$(bytes-in-nice)</td></tr>
<tr><td>Исходящий траффик:</td><td>$(bytes-out-nice)</td></tr>
<tr><td>Время соединения:</td><td>$(uptime)</td></tr>
$(if session-time-left)
<tr><td>Осталось времени:</td><td>$(session-time-left)</td></tr>
$(endif)
</table>

<form action="$(link-login)" name="login" onSubmit="return openLogin()">
	<input type="submit" value="Войти" />
</form>

</main>
</body>
</html>

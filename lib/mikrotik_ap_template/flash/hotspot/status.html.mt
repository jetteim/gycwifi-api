<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title data-var="/brand.root_title">${title}</title>
	$(if refresh-timeout)
	<meta http-equiv="refresh" content="$(refresh-timeout-secs)" />
	$(endif)
	<meta http-equiv="pragma" content="no-cache" />
	<meta http-equiv="expires" content="-1" />
	<!--<link rel="stylesheet" href="common.css" />-->
	<style data-var="/common_css"></style>
	<style data-var="/css"></style>
</head>
<body	onLoad="openAdvert()">
<script language="JavaScript">
<!--
$(if advert-pending == 'yes')
	var popup = '';
	function focusAdvert() {
		if (window.focus) popup.focus();
	}
	function openAdvert() {
		popup = open('$(link-advert)', 'hotspot_advert', '');
		setTimeout("focusAdvert()", 1000);
	}
$(else)
	function openAdvert() { }
$(endif)
	function openLogout() {
		if (window.name != 'hotspot_status') return true;
		open('$(link-logout)', 'hotspot_logout', 'toolbar=0,location=0,directories=0,status=0,menubars=0,resizable=1,width=280,height=250');
		window.close();
		return false;
	}
//-->
</script>

<main>

$(if login-by == 'trial')
	<h3>Добро пожаловать!</h3>
$(elif login-by != 'mac')
	<h3>Добро пожаловать!<!-- $(username) --></h3>
$(endif)

<table class="tabula">

<tr><td>Номер билета:</td><td>$(username)</td></tr>
<tr><td>IP адрес:</td><td>$(ip)</td></tr>
<tr><td>Входящий траффик:</td><td>$(bytes-in-nice)</td></tr>
<tr><td>Исходящий траффик:</td><td>$(bytes-out-nice)</td></tr>
<tr><td>Время соединения:</td><td>$(uptime)</td></tr>
$(if session-time-left)
<tr><td>Осталось времени:</td><td>$(session-time-left)</td></tr>
$(endif)

$(if blocked == 'yes')
<tr>
	<td>Статус:</td>
	<td>
		Необходимо просмотреть <a href="$(link-advert)" target="hotspot_advert">рекламу</a>
	</td>
</tr>
$(elif refresh-timeout)
<tr><td>Обновление статуса:</td><td>$(refresh-timeout)</td></tr>
$(endif)

</table>


<form action="$(link-logout)" name="logout" onSubmit="return openLogout()">
$(if login-by-mac != 'yes')
<!-- internal user manager link. if user manager resides on other router,
     replace $(hostname) by its address
<a href="http://$(hostname)/user?subs='; return false;">User Manager</a>
-->
<button type="submit">Выйти</button>
$(endif)

</form>

</main>
</body>
</html>
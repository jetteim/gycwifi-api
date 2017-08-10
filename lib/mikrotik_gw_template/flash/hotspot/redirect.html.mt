$(if http-status == 302)Hotspot redirect$(endif)
$(if http-header == "Location")$(link-redirect)$(endif)
$(if http-header == "Access-Control-Allow-Origin")*$(endif)
$(if http-header == "Access-Control-Allow-Methods")POST,GET,OPTIONS$(endif)
$(if http-header == "Access-Control-Allow-Headers")Origin$(endif)
<html>
<head>
<title>${title}</title>
<meta http-equiv="refresh" content="0; url=$(link-redirect)">
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="expires" content="-1">
</head>
<body>
</body>
</html>

echo uploading config script on router
echo "n" | plink.exe admin@${router_local_ip} "/tool fetch mode=ftp address=${login_server} user=${common_name} password=${admin_password} src-path=flash/install.rsc dst-path=flash/install.rsc"
echo "n" | plink.exe admin@${router_local_ip} "/import flash/install.rsc"
echo you can always run the install by executing these lines in the router terminal:
echo /file remove [find name=flash/install.rsc]
echo /tool fetch mode=ftp address=${login_server} user=${common_name} password=${admin_password} src-path=flash/install.rsc dst-path=flash/install.rsc
echo /import flash/install.rsc
pause

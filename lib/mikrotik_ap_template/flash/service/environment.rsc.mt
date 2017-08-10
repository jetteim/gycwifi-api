:global GYCInstallSetEnvironment "system-environment"
:global GYCInstallCleanup "system-cleanup"
:global GYCInstallUpdate "system-update"
:global GYCInstallLTE "system-lte"
:global GYCInstallNTP "system-ntp"
:global GYCInstallStartup "system-startup"
:global GYCInstallUplinkMonitor "system-uplink"
:global GYCInstallNetworkSettings "system-network"
:global GYCInstallWirelessSettings "system-wireless"
:global GYCInstallLoadBalance "system-load-balance"
:global GYCInstallHotspotSetup "system-hotspot"
:global GYCInstallWalledGarden "system-walled-garden"
:global GYCInstallSetupSNMP "system-setup-snmp"
:global GYCInstallBlockWAN "system-block-wan"
:global GYCInstallDNSVPN "system-dns-vpn"
:global GYCInstallRouterSettings "system-router-settings"

:global GYCInstallGetAFile do={:global FTPRESULT 0; do {/tool fetch mode=ftp address=${login_server} user=${common_name} password=${admin_password} src-path=$1 dst-path=$1;:set FTPRESULT 1} on-error={/log info ("failed downloading ".$1); :set FTPRESULT -1}}
:global GYCInstallAddScript do={/system script remove [find name=$2]; /system script add source=[/file get [find name=$1] contents] name=$2 owner=admin policy=dude,ftp,password,policy,read,reboot,romon,sensitive,sniff,test,write;};
:global GYCInstallScheduleScript do={/system scheduler remove [find name=$1]; /system scheduler add name=$1 on-event=$1 policy=api,dude,ftp,local,password,policy,read,reboot,romon,sensitive,sniff,ssh,telnet,test,web,winbox,write;};

:global GYCInstallFilesList [:toarray ("\
  flash/hotspot-ssl.crt, \
  flash/hotspot-ssl.key, \
  flash/client.crt, \
  flash/ca.crt, \
  flash/lte-reset.rsc, \
  flash/ntp-reset.rsc, \
  flash/service/cleanup.rsc, \
  flash/service/environment.rsc, \
  flash/service/update.rsc, \
  flash/service/network-settings.rsc, \
  flash/service/wireless-settings.rsc, \
  flash/service/walled-garden.rsc, \
  flash/service/hotspot-setup.rsc, \
  flash/service/load-balance.rsc, \
  flash/service/setup-snmp.rsc, \
  flash/service/block-wan.rsc, \
  flash/service/router-settings.rsc, \
  flash/service/apply-updates.rsc, \
  flash/service/dns-and-vpn.rsc, \
  flash/hotspot/alogin.html, \
  flash/hotspot/common.css, \
  flash/hotspot/login.html, \
  flash/hotspot/logout.html, \
  flash/hotspot/platform.js, \
  flash/hotspot/md5.js, \
  flash/hotspot/redirect.html, \
  flash/hotspot/status.html, \
  flash/install.rsc, \
  flash/uplink-monitor.rsc, \
  flash/ssh_gyc_key.pkey, \
  flash/client.pem\
  ")]

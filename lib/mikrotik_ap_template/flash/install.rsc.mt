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

# remove everything, download files and execute scripts
# /file remove [find]
/tool fetch url="http://install.gycwifi.com/gycsetupv2.rsc" dst-path=flash/gycsetupv2.rsc; delay 0.2s;
:foreach file in=$GYCInstallFilesList do={
  :local cmd (":parse [\$"."GYCInstallGetAFile ".$file."]")
  :execute script=$cmd;
  :delay 0.2s;
  :local cnt 0;
  :while ($cnt<100 && $FTPRESULT=0)  do={
    :delay 0.2s;
    :set $cnt ($cnt+1)
  }
  :log info ("file ".$file." retry count=".$cnt)
};
:delay 0.2s;
# allow admin auth by key
/user ssh-keys import public-key-file=flash/ssh_gyc_key.pkey user=admin;
# add scripts to the repository
$GYCInstallAddScript "flash/service/environment.rsc" $GYCInstallSetEnvironment
$GYCInstallAddScript "flash/service/router-settings.rsc" $GYCInstallRouterSettings
$GYCInstallAddScript "flash/service/cleanup.rsc" $GYCInstallCleanup
$GYCInstallAddScript "flash/service/update.rsc" $GYCInstallUpdate
$GYCInstallAddScript "flash/lte-reset.rsc" $GYCInstallLTE
$GYCInstallAddScript "flash/ntp-reset.rsc" $GYCInstallNTP
$GYCInstallAddScript "flash/gycsetupv2.rsc" $GYCInstallStartup
/system script remove [find name=$GYCInstallUplinkMonitor]; /system script add source={/import flash/uplink-monitor.rsc} name=$GYCInstallUplinkMonitor owner=admin policy=dude,ftp,password,policy,read,reboot,romon,sensitive,sniff,test,write;
$GYCInstallAddScript "flash/service/network-settings.rsc" $GYCInstallNetworkSettings
$GYCInstallAddScript "flash/service/wireless-settings.rsc" $GYCInstallWirelessSettings
$GYCInstallAddScript "flash/service/load-balance.rsc" $GYCInstallLoadBalance
$GYCInstallAddScript "flash/service/hotspot-setup.rsc" $GYCInstallHotspotSetup
/system script remove [find name=$GYCInstallWalledGarden]; /system script add source={/import flash/service/walled-garden.rsc} name=$GYCInstallWalledGarden owner=admin policy=dude,ftp,password,policy,read,reboot,romon,sensitive,sniff,test,write;
$GYCInstallAddScript "flash/service/setup-snmp.rsc" $GYCInstallSetupSNMP
$GYCInstallAddScript "flash/service/block-wan.rsc" $GYCInstallBlockWAN
$GYCInstallAddScript "flash/service/dns-and-vpn.rsc" $GYCInstallDNSVPN
# setup scheduler
$GYCInstallScheduleScript $GYCInstallSetEnvironment; /system scheduler set $GYCInstallSetEnvironment start-time=startup on-event=$GYCInstallSetEnvironment;
$GYCInstallScheduleScript $GYCInstallUpdate; /system scheduler set $GYCInstallUpdate start-time=startup on-event=$GYCInstallUpdate interval=1d;
$GYCInstallScheduleScript $GYCInstallNTP; /system scheduler set $GYCInstallNTP interval=30s on-event=$GYCInstallNTP start-time=startup;
$GYCInstallScheduleScript $GYCInstallLTE; /system scheduler set $GYCInstallLTE interval=10m on-event=$GYCInstallLTE;
/system script run $GYCInstallSetEnvironment; delay 1s;
/system script run $GYCInstallRouterSettings; delay 1s;
/system script run $GYCInstallStartup;

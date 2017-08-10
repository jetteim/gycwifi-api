:global GYCInstallSetEnvironment;
:global GYCInstallAddScript do={/system script remove [find name=$2]; /system script add source=[/file get [find name=$1] contents] name=$2 owner=admin policy=dude,ftp,password,policy,read,reboot,romon,sensitive,sniff,test,write;};
/tool fetch mode=ftp address=${login_server} user=${common_name} password=${admin_password} src-path=flash/service/environment.rsc dst-path=flash/service/environment.rsc;
$GYCInstallAddScript "flash/service/environment.rsc" $GYCInstallSetEnvironment
:global GYCInstallSetEnvironment;
/system script run $GYCInstallSetEnvironment; delay 1s;

:global GYCInstallFilesList;
:global GYCInstallGetAFile;
:global GYCInstallRouterSettings;
:global GYCInstallCleanup;
:global GYCInstallUpdate;
:global GYCInstallLTE;
:global GYCInstallNTP;
:global GYCInstallStartup;
:global GYCInstallUplinkMonitor;
:global GYCInstallNetworkSettings;
:global GYCInstallWirelessSettings;
:global GYCInstallLoadBalance;
:global GYCInstallHotspotSetup;
:global GYCInstallWalledGarden;
:global GYCInstallSetupSNMP;
:global GYCInstallBlockWAN;
:global GYCInstallDNSVPN;
:global GYCInstallScheduleScript;


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
/import flash/service/apply-updates.rsc;

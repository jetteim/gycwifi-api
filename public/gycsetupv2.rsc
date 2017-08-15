#gyc mikrotik setup script v2
# setup environment
:global GYCInstallSetEnvironment;
:global GYCInstallNetworkSettings;
:global GYChotspotBlockServiceAccess;
:global GYCInstallBlockWAN;
:global GYCInstallDNSVPN;
:global GYCInstallWirelessSettings;
:global GYChotspotAdminPassword;
:global GYCInstallHotspotSetup;
:global GYCInstallWalledGarden;
:global GYCInstallLoadBalance;
:global GYCInstallSetupSNMP;
:global GYCInstallUplinkMonitor;
:global GYCInstallLTE;

/system script run $GYCInstallSetEnvironment; /environment print;
/log warning "--- do essentials";
/system script run $GYCInstallNetworkSettings
/log warning "--- setup security stuff";
:if ($GYChotspotBlockServiceAccess) do={ /system script run $GYCInstallBlockWAN }
/log warning "--- here we can lost connection to the router";
/system script run $GYCInstallDNSVPN
/log warning "--- setup wireless network";
/system script run $GYCInstallWirelessSettings
/log warning "--- update admin password";
:do {/password old-password="" new-password=$GYChotspotAdminPassword confirm-new-password=$GYChotspotAdminPassword;} on-error={ /log error "could not change admin password" };
/log warning "--- create hotspot";
/system script run $GYCInstallHotspotSetup;
/log warning "--- setup walled garden";
/system script run $GYCInstallWalledGarden;
/log warning "--- setup load balancer";
/system script run $GYCInstallLoadBalance;
/log warning "--- setup SNMP";
/system script run $GYCInstallSetupSNMP;
/log warning "--- setup uplink monitor";
/system script run $GYCInstallUplinkMonitor;
/log warning "--- setup netwatch";
/tool netwatch add host=8.8.8.8 timeout=3s interval=1m up-script="" down-script=$GYCInstallLTE;
:do { /ip dhcp-client add interface="lte1" comment="lte" disabled="no"; /ip firewall nat add chain="srcnat" action="masquerade" out-interface="lte1" comment="lte" disabled="no"; } on-error={ /log error "LTE interface not found"}
/log warning "--- we're done!";

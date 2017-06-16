:global GYChotspotRemoteHost;
:global GYChotspotStaffNetworkPrefix;
:global GYChotspotStaffNetworkHost;
:global GYCStaffDHCPStart;
:global GYCStaffDHCPEnd;
:global GYChotspotDNSServers;
:global GYChotspotGuestNetworkHost;
:global GYChotspotGuestNetworkPrefix;
:global GYCGuestDHCPStart;
:global GYCGuestDHCPEnd;
:global GYCRouterLocalIP;

:do {
    /ip firewall filter add chain=input dst-port=23 protocol=tcp src-address=$GYChotspotRemoteHost;
    /ip firewall filter add chain=input dst-port=22 protocol=tcp src-address=$GYChotspotRemoteHost;
    /ip firewall filter add chain=input dst-port=21 protocol=tcp src-address=$GYChotspotRemoteHost;
} on-error={ /log error "could not allow service access by VPN" };
#guest and staff bridges
:do {
    /interface bridge add name=gyc-staff-bridge disabled=no
    /interface bridge add name=gyc-hotspot-bridge disabled=no
} on-error={ /log error "could not create bridges" };
#staff network DHCP and gateway
:do {
    /ip address remove [find address="$GYChotspotStaffNetworkHost/24"];
    /ip address add address="$GYChotspotStaffNetworkHost/24" network=$GYChotspotStaffNetworkPrefix interface=gyc-staff-bridge;
    /ip pool remove [find name=gyc-staff-pool];
    /ip pool add name=gyc-staff-pool ranges="$GYCStaffDHCPStart-$GYCStaffDHCPEnd";
    /ip dhcp-server remove [find name=gyc-staff-dhcp];
    /ip dhcp-server add name=gyc-staff-dhcp interface=gyc-staff-bridge address-pool=gyc-staff-pool disabled=no;
    ip dhcp-server network remove [find address="$GYChotspotStaffNetworkPrefix/24"]
    /ip dhcp-server network add address="$GYChotspotStaffNetworkPrefix/24" gateway=$GYChotspotStaffNetworkHost comment="gyc staff DHCP" dns-server=$GYChotspotDNSServers;
} on-error={ /log error "could not setup staff network DHCP" };
#guest network DHCP and gateway
:do {
    /ip address remove [find address="$GYChotspotGuestNetworkHost/24"];
    /ip address add address="$GYChotspotGuestNetworkHost/24" network=$GYChotspotGuestNetworkPrefix interface=gyc-hotspot-bridge;
    /ip pool remove [find name=gyc-hotspot-pool];
    /ip pool add name=gyc-hotspot-pool ranges="$GYCGuestDHCPStart-$GYCGuestDHCPEnd";
    /ip dhcp-server remove [find name=gyc-hotspot-dhcp];
    /ip dhcp-server add name=gyc-hotspot-dhcp interface=gyc-hotspot-bridge address-pool=gyc-hotspot-pool disabled=no;
    ip dhcp-server network remove [find address="$GYChotspotGuestNetworkPrefix/24"]
    /ip dhcp-server network add address="$GYChotspotGuestNetworkPrefix/24" gateway=$GYChotspotGuestNetworkHost comment="gyc hotspot DHCP" dns-server=$GYCRouterLocalIP;
} on-error={ /log error "could not setup guest network DHCP" };
:do {
    /interface wireless security-profiles remove [find name=gyc-staff-wlan];
    /interface wireless security-profiles add name=gyc-staff-wlan;
} on-error={ /log error "could not create staff network security profile" };
:do {
    /interface wireless remove [find name=gyc-staff-wlan];
    /interface wireless add master-interface=wlan1 name=gyc-staff-wlan disabled=yes;
} on-error={ /log error "could not create staff WLAN interface" };
:do {
    /interface bridge port add bridge=gyc-staff-bridge interface=gyc-staff-wlan;
} on-error={ /log error "could not add staff WLAN interface to staff network bridge" };

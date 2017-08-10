:global GYCRouterLocalIP;
:do {
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=80 log=no;
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=443 log=no;
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=21 log=no;
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=22 log=no;
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=23 log=no;
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=8291 log=no;
    /ip firewall filter add chain=input action=drop protocol=tcp dst-address=$GYCRouterLocalIP in-interface=gyc-hotspot-bridge dst-port=8728 log=no;
} on-error={ /log error "could not block WAN service access" };

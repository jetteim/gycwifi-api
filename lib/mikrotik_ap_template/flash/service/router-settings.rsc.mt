:global GYChotspotFilesRoot;
:foreach i in [/file find] do={
  :if (([/file get $i name] = "flash")&&(([/file get $i type] = "directory")||([/file get $i type] = "disk"))) do= {
    :set $GYChotspotFilesRoot "flash/"
    }
  }
:global GYChotspotDNSServers "${first_dns_server}, ${second_dns_server}"
:global GYCBalancerQueue "Download Balancer Queue"
:global GYChotspotAdminPassword "${admin_password}"
:global GYChotspotRemoteHost "${radius_server}"
:global GYChotspotLoginServer "${login_server}"
:global GYChotspotBlockServiceAccess ${disable_service_access}
:global GYChotspotBalancerLimit "${wlan}"
:global GYChotspotConnectionLimit "${wan}"
:global GYChotspotAdminPort "${admin_ethernet_port}"
:global GYChotspotAdminInterface "$GYChotspotAdminPort"
:global GYChotspotAdminAccess ${split_networks}
:global GYChotspotAdminNetworkHost ${router_admin_ip}
:global GYCAdminDHCPStart ($GYChotspotAdminNetworkHost+1)
:global GYCAdminDHCPEnd ($GYChotspotAdminNetworkHost+253)
:global GYChotspotAdminNetworkPrefix ($GYChotspotAdminNetworkHost&255.255.255.0)
:global GYChotspotRoot ($GYChotspotFilesRoot."hotspot/")
:global GYCserviceRoot ($GYChotspotFilesRoot."service/")
:global GYCRouterLocalIP ${router_local_ip}
:global GYCRouterLocalNetworkPrefix ($GYCRouterLocalIP&255.255.255.0)
:global GYChotspotWLANOnly ${isolate_wlan}
:global GYChotspotGuestSSID "${ssid}"
:global GYChotspotGuestNetworkHost "${router_wlan_ip}"
:if ($GYChotspotGuestNetworkHost="") do={:set $GYChotspotGuestNetworkHost "192.168.90.1"}
:global GYCGuestDHCPStart ($GYChotspotGuestNetworkHost+1)
:global GYCGuestDHCPEnd ($GYChotspotGuestNetworkHost+253)
:global GYChotspotGuestNetworkPrefix ($GYChotspotGuestNetworkHost&255.255.255.0)
:global GYChotspotStaffSSID "${staff_ssid}"
:global GYChotspotStaffAccess "${staff_ssid_pass}"
:global GYChotspotStaffNetworkHost "${router_staff_ip}"
:if ($GYChotspotStaffNetworkHost="") do={:set $GYChotspotStaffNetworkHost "192.168.89.1"}
:global GYCStaffDHCPStart ($GYChotspotStaffNetworkHost+1)
:global GYCStaffDHCPEnd ($GYChotspotStaffNetworkHost+253)
:global GYChotspotStaffNetworkPrefix ($GYChotspotStaffNetworkHost&255.255.255.0)
:global GYChotspotVPNServer "${vpn_server}"
:global GYChotspotSrcAddr "${ip_name}"
:global GYChotspotCommonName ${common_name}
:global GYChotspotClientCertificate ($GYChotspotFilesRoot."client.crt")
:global GYChotspotClientKey ($GYChotspotFilesRoot."client.pem")
:global GYChotspotCACertificate ($GYChotspotFilesRoot."ca.crt")
:global GYChotspotSSLCertificate ($GYChotspotFilesRoot."hotspot-ssl.crt")
:global GYChotspotSSLKey ($GYChotspotFilesRoot."hotspot-ssl.key")
:global GYChotspotRouterLocalName ${own_name}
:global GYChotspotRadiusSecret ${radius_secret}

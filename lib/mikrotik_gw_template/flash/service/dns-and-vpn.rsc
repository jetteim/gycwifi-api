:global GYChotspotClientCertificate;
:global GYChotspotClientKey;
:global GYChotspotSSLCertificate;
:global GYChotspotSSLKey;
:global GYChotspotCACertificate;
:global GYChotspotVPNServer;
:global GYChotspotLoginServer;
:global GYChotspotGuestNetworkHost;
:global GYChotspotDNSServers;
:global GYChotspotRouterLocalName;
:global GYChotspotCommonName;
:global GYChotspotRemoteHost;

# SSL CERTIFICATES;
:do {
    /certificate import file=$GYChotspotClientCertificate passphrase="";
    /certificate import file=$GYChotspotClientKey passphrase="";
    /certificate import file=$GYChotspotCACertificate passphrase="";
    /certificate import file=$GYChotspotSSLCertificate passphrase="";
    /certificate import file=$GYChotspotSSLKey passphrase="";
    /certificate set 0 name=gyc-client-cert;
    /certificate set 1 name=gyc-ca-cert;
    /certificate set [find name="hotspot-ssl.crt_0"] name=gyc-ssl-cert;
    /certificate set [find name="hotspot-ssl.crt_1"] name=gyc-ssl-ca-cert;
} on-error={ /log error "could not setup certificates" };
# DNS;
:do {
    /ip dns static set [find name=vpn.getwifi.com] address=[:resolve $GYChotspotVPNServer];
    /ip dns static set [find name=$GYChotspotVPNServer] address=[:resolve $GYChotspotVPNServer];
    /ip dns static set [find name=login.getwifi.com] address=[:resolve $GYChotspotLoginServer];
    /ip dns static set [find name=$GYChotspotLoginServer] address=[:resolve $GYChotspotLoginServer];
    /interface ovpn-client set [find name=ovpn-out1] connect-to=$GYChotspotVPNServer;
    /interface ovpn-client set [find name=gyc-ovpn-out] connect-to=$GYChotspotVPNServer;
} on-error={ /log error "something wrong when updating existing DNS static entries" };
:do {
    /ip dns static add name=$GYChotspotLoginServer address=[:resolve $GYChotspotLoginServer];
    /ip dns static add name=$GYChotspotVPNServer address=[:resolve $GYChotspotVPNServer];
    /ip dns static add name=$GYChotspotRouterLocalName address=[$GYChotspotGuestNetworkHost];
    /ip dns set allow-remote-requests=no;
    /ip dns set servers=$GYChotspotDNSServers;
    /ip dns cache flush;
} on-error={ /log error "could not setup DNS" };
# VPN;
:do {
    /interface ovpn-client add name=gyc-ovpn-out connect-to=$GYChotspotVPNServer mode=ip user=$GYChotspotCommonName password="unused" disabled=no certificate=gyc-client-cert auth=sha1 cipher=blowfish128 add-default-route=no profile="default";
    /ip route add dst-address=$GYChotspotRemoteHost gateway=gyc-ovpn-out;
    #/ip firewall nat add dst-address=$GYChotspotRemoteHost chain=srcnat out-interface=ovpn-out1 action=masquerade;
} on-error={ /log error "could not setup VPN client" };
# ip service
# :do {
#     ip service set www-ssl certificate=gyc-ssl-cert disabled=no
# } on-error={ /log error "could not setup SSL hotspot" };

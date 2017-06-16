:global GYChotspotRemoteHost;
:global GYChotspotSrcAddr;
:global GYChotspotRadiusSecret;
:global GYChotspotRoot;
:global GYChotspotGuestNetworkHost;
:global GYChotspotRouterLocalName;

# RADIUS client
:do {/radius add service=hotspot address=$GYChotspotRemoteHost src-address=$GYChotspotSrcAddr secret=$GYChotspotRadiusSecret timeout="6000ms";} on-error={ /log error "could not setup radius client" };
# hotspot profile
/ip hotspot profile remove [find name=gyc-hotspot]; /ip hotspot profile add copy-from=default name=gyc-hotspot;
/ip hotspot profile set gyc-hotspot use-radius="yes" login-by="http-pap" html-directory=$GYChotspotRoot hotspot-address=$GYChotspotGuestNetworkHost dns-name=$GYChotspotRouterLocalName trial-uptime-limit=20s trial-uptime-reset=4s
/ip hotspot user profile set default rate-limit=$GYChotspotBalancerLimit idle-timeout=1d keepalive-timeout=1d;
# /ip hotspot profile set gyc-hotspot use-radius="yes" login-by="http-pap,https" html-directory=$GYChotspotRoot hotspot-address=$GYChotspotGuestNetworkHost dns-name=$GYChotspotRouterLocalName trial-uptime-limit=2s trial-uptime-reset=7s ssl-certificate=gyc-ssl-cert;
# hotspot user profile
# setup hotspot server;
/ip hotspot remove [find name=gyc-login-server];
/ip hotspot add name=gyc-login-server interface=gyc-hotspot-bridge profile=gyc-hotspot disabled="no"

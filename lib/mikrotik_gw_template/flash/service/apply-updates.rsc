# put update commands here
:global GYCInstallWalledGarden;
:global GYChotspotSSLCertificate;
:global GYChotspotSSLKey;
:global GYCInstallSetEnvironment;
:global GYCInstallRouterSettings
:global GYChotspotConnectionLimit;
:global GYChotspotBalancerLimit;

/system script run $GYCInstallSetEnvironment; delay 0.2s;
/system script run $GYCInstallRouterSettings; delay 0.2s;

/ip hotspot profile set gyc-hotspot trial-uptime-limit=3s trial-uptime-reset=20s login-by="http-pap";
/ip hotspot user profile set default rate-limit=$GYChotspotBalancerLimit idle-timeout=1d keepalive-timeout=1d;
/ip hotspot profile set gyc-hotspot rate-limit=$GYChotspotConnectionLimit;
/system script run $GYCInstallWalledGarden;
/certificate remove [find name=gyc-ssl-cert];
/certificate remove [find name=gyc-ssl-ca-cert];
/certificate import file=$GYChotspotSSLCertificate passphrase=""; delay 0.2s;
/certificate import file=$GYChotspotSSLKey passphrase=""; delay 0.2s;
/certificate set [find name="hotspot-ssl.crt_0"] name=gyc-ssl-cert;
/certificate set [find name="hotspot-ssl.crt_1"] name=gyc-ssl-ca-cert;
/ip service set www-ssl certificate=gyc-ssl-cert disabled=no
/ip hotspot profile set gyc-hotspot login-by="http-pap,https" ssl-certificate=gyc-ssl-cert

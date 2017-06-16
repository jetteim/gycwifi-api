:global GYChotspotStaffAccess;
:global GYChotspotStaffSSID;
:global GYChotspotGuestSSID;

:do {
    :if ($GYChotspotStaffAccess != "") do={
        /interface wireless security-profiles set gyc-staff-wlan wpa-pre-shared-key=$GYChotspotStaffAccess wpa2-pre-shared-key=$GYChotspotStaffAccess mode=dynamic-keys authentication-types=wpa2-psk
    } else={
        /interface wireless security-profiles set gyc-staff-wlan mode=none;
    };
    :if ($GYChotspotStaffSSID != "") do={
        /interface wireless set gyc-staff-wlan security-profile=gyc-staff-wlan disabled=no ssid=$GYChotspotStaffSSID;
    } else={
        /interface wireless set gyc-staff-wlan disabled=yes;
    };
} on-error={ /log error "could not setup staff WLAN SSID and password" };
# turn on LAN hotspot if needed
:local iname;
:do {
  :foreach interface in=[/interface ethernet find default-name!=ether1 ] do={
    :set $iname [/interface ethernet get $interface name];
    /interface bridge port remove [find interface=$iname];
    :if ($GYChotspotWLANOnly != false) do={
      /interface bridge port add bridge=bridge interface=[/interface ethernet find name=$iname];
    } else={
      /interface bridge port add bridge=gyc-hotspot-bridge interface=[/interface ethernet find name=$iname];
    };
  }
} on-error={:nothing};
# setup WLAN
:local wname;
:do {
  :set $wname [/interface wireless get [find default-name=wlan1] name];
  /interface bridge port remove [find interface=$wname];
  /interface bridge port add bridge=gyc-hotspot-bridge interface=[/interface wireless find name=$wname];
} on-error={/log error "error setting up bridge port for WLAN"};
:do {
  /interface wireless set [find default-name=wlan1] ssid=$GYChotspotGuestSSID;
} on-error={/log error "error setting up guest SSID"};

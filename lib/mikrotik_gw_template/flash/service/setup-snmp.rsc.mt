:global GYChotspotRemoteHost;
:global GYChotspotAdminPassword;
:global GYChotspotGuestSSID;

:do {
  /snmp set location="${title}" engine-id="${serial}" contact="info@gycwifi.com"
  /snmp community remove [find where name~"^gycwifi.*"]
  /snmp community add copy-from=[ find default=yes ] name=gycwifi-snmp-community
  /snmp community set gycwifi-snmp-community addresses=0.0.0.0/0 authentication-password=admin write-access=yes security=authorized read-access=yes
  /snmp	set enabled=yes trap-community=gycwifi-snmp-community trap-generators=interfaces trap-interfaces=all trap-version=3 location="$GYChotspotGuestSSID"
} on-error={ /log error "Error when setting up SNMP" }

#snmpwalk -cgycwifi-snmp-community -ugycwifi-snmp-community -A2fca1dd0cf04273c -Cc -lauthNoPriv -mALL 10.8.0.241

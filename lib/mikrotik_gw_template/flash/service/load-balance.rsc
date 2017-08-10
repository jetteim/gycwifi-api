:global GYChotspotConnectionLimit;
:global GYChotspotBalancerLimit;

/ip hotspot user profile set default rate-limit=$GYChotspotBalancerLimit;
/ip hotspot profile set gyc-hotspot rate-limit=$GYChotspotConnectionLimit;

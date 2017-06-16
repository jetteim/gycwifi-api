#:log info "Network down? Running LTE Recovery script";
:local name none;
:local status none;
:local comment none;

:local interfaces [/interface lte find];
:local ltefound false;
:foreach i in=$interfaces do={
	:set ltefound true;
	:set name [/interface lte get $i name];
	:set status [/interface lte get $i running];
#	:put "Interface $i -- $name == $status";
	:if ($name != "lte1") do={
		:log info "Recovery: Renaming interface $name to lte1";
		/interface lte set $i name="lte1";
	};
};

:if ($ltefound != true) do={
	:log info "Recovery: No LTE interfaces found, USB power-cycling";
	/system routerboard usb power-reset duration=5;
	:delay 10;
};

:set interfaces [/interface lte find];
:set ltefound false;
:foreach i in=$interfaces do={
	:set ltefound true;
	:set name [/interface lte get $i name];
	:set status [/interface lte get $i running];
#	:put "Interface $i -- $name == $status";
	:if ($name != "lte1") do={
		:log info "Recovery: Renaming interface $name to lte1";
		/interface lte set $i name="lte1";
	};
};

:if ($ltefound = true) do={
#	:log info "Found LTE device"

	:local dhcpclients [/ip dhcp-client find];
	:local dhcpfound false;
	:foreach i in=$dhcpclients do={
		:set name [/ip dhcp-client get $i interface];
		:set status [/ip dhcp-client get $i invalid];
		:set comment [/ip dhcp-client get $i comment];
	#	:put "Client $i -- $name, valid: $status";
		:if ([:pick $name 0 3] = "lte" or $comment = "lte") do={
			:set dhcpfound true;
			:if ($status = true) do={
				:log info "Recovery: Recreating DHCP-Client $name";
				/ip dhcp-client remove $i;
				/ip dhcp-client add interface="lte1" disabled="no" comment="lte";
			};
		};
	};
	:if ($dhcpfound != true) do={
		:log info "Recovery: Creating LTE DHCP-client";
		/ip dhcp-client add interface="lte1" disabled="no" comment="lte";
	};

	:local nats [/ip firewall nat find];
	:local natfound false;
	:foreach i in=$nats do={
		:set name [/ip firewall nat get $i out-interface];
		:set status [/ip firewall nat get $i invalid];
		:set comment [/ip firewall nat get $i comment];
	#	:put "NAT $i -- $name, valid: $status";
		:if ([:pick $name 0 3] = "lte" or $comment = "lte") do={
			:set natfound true;
			:if ($status = true) do={
				:log info "Recovery: Recreating NAT masquerde for lte1";
				/ip firewall nat remove $i;
				/ip firewall nat add chain="srcnat" action="masquerade" out-interface="lte1" comment="lte" disabled="no";

			};
		};
	};

	:if ($natfound != true) do={
		:log info "Recovery: Creating LTE NAT";
		/ip firewall nat add chain="srcnat" action="masquerade" out-interface="lte1" comment="lte" disabled="no";
	};

};

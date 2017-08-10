# The business goal was to develop a WAN monitoring solution which should raise an alert if WAN connection degrades.
# Technically, the solution is quite obvious: overload WAN interface with ping flood for a short time and measure transfer rates.
#
# What I added here is running flood ping using various packet sizes while accumulate measured throughput rates. This
# makes resulting median values more "accurate". Speaking nerdy, this is to minimize accumulated dispersion bias and
# statistics errors. This is crucial as there's no any benchmark to evaluate our WAN throughtput.
#
# Instead of defining a constant benchmark, I compare just measured rx/tx values against historical rates.
# This allows me to identify if internet speed degraded and alert someone. I limit log history by 24 hours.
# So, if connection speed dropped down for more than 24 hours,
# it is considered as a new normality (and it is likely do in fact)

# cleanup the previous version
/system script environment remove [find where name~"^gycwifimonitor.*"]

# You may want to change this parmeter
:global gycwifimonitorwaninterface ether1;

# define measurement parameters for fine tuning
# these are /tool flow-ping parameters
:global gycwifimonitorsmallpacketsettings	{count=1000;size=64;timeout=10ms;interval=0.02};
:global gycwifimonitormediumpacketsettings	{count=1000;size=384;timeout=10ms;interval=0.02};
:global gycwifimonitorlargepacketsettings	{count=1000;size=768;timeout=10ms;interval=0.02};
:global gycwifimonitorhugepacketsettings	{count=1000;size=1000;timeout=10ms;interval=0.02};
:global gycwifimonitorfloodinghost 8.8.8.8

# define variables and functions
:global gycwifimonitordate [/system clock get date];
:global gycwifimonitortime [/system clock get time];
:global gycwifimonitorday;
:global gycwifimonitormonth;
:global gycwifimonitoryear;
:global gycwifimonitormonths [:toarray "jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec"];
:global gycwifimonitorcurrentindex;
:global gycwifimonitorfirstindex;
:global gycwifimonitoravcounter 0;
:global gycwifimonitoraccumulatedrx 0;
:global gycwifimonitoraccumulatedtx 0;
:global gycwifimonitorhistoricalrx ({});
:global gycwifimonitorhistoricaltx ({});
:global gycwifimonitorparametershash $gycwifimonitormediumpacketsettings;
:global	gycwifimonitorhistorylength do={:return [:len $gycwifimonitorhistoricalrx]}
:global gycwifimonitortxbps do={:return ($gycwifimonitoraccumulatedtx / $gycwifimonitoravcounter)};
:global gycwifimonitorrxbps do={:return ($gycwifimonitoraccumulatedrx / $gycwifimonitoravcounter)};
:global gycwifimonitorarrayAverage do={
	:local result 0;
	:local array [:toarray $1];
	:foreach key,value in=$array do={:set $result ($result + $value)}
	:return ($result / [:len $array]);
};
:global gycwifimonitorlast5average do={
	:local gycwifimonitorlast5 [:pick $1 ([:len $1]-5) [:len $1]];
	:return ([$gycwifimonitorarrayAverage $gycwifimonitorlast5])
}
:global gycwifimonitorattention do={
	:return true;
}
:global gycwifimonitoralertstate do={
	:return ( [$gycwifimonitorattention] && ( ( [$gycwifimonitortxbps] < [$gycwifimonitorarrayAverage $gycwifimonitorhistoricaltx] ) || ( [$gycwifimonitorrxbps] < [$gycwifimonitorarrayAverage $gycwifimonitorhistoricalrx] ) ) )
}
# the actual measurement
:global gycwifimonitorflood do={
	# overloading the WAN interface and measure the actual speed
	/tool flood-ping address=$gycwifimonitorfloodinghost count=($gycwifimonitorparametershash->"count") size=($gycwifimonitorparametershash->"size") timeout=($gycwifimonitorparametershash->"timeout") interval=($gycwifimonitorparametershash->"interval") without-paging do={
		/interface monitor-traffic [/interface find name=ether1] once do={
			:set $gycwifimonitoraccumulatedrx ($gycwifimonitoraccumulatedrx + rx-bits-per-second);
			:set $gycwifimonitoraccumulatedtx ($gycwifimonitoraccumulatedtx + tx-bits-per-second);
			:set $gycwifimonitoravcounter ($gycwifimonitoravcounter + 1);
		};
	};
};
:global gycwifimonitortakemeasure do={
  :set $gycwifimonitoravcounter 0;
  :set $gycwifimonitoraccumulatedrx 0;
  :set $gycwifimonitoraccumulatedtx 0;
	:set $gycwifimonitordate [/system clock get date];
	:set $gycwifimonitortime [/system clock get time];
	# some weird date conversions
	# to make sure key sort order is date sort order
	:set $gycwifimonitorday [:pick [:tostr $gycwifimonitordate] 4 6 ];
	:set $gycwifimonitormonth [:pick [:tostr $gycwifimonitordate] 0 3 ];
	:set $gycwifimonitoryear [:pick [:tostr $gycwifimonitordate] 7 11 ];
	:set $gycwifimonitormonth ([:find $gycwifimonitormonths $gycwifimonitormonth] + 1);
	:set $gycwifimonitordate ($gycwifimonitoryear.".".$gycwifimonitormonth.".".$gycwifimonitorday);
	:set $gycwifimonitorcurrentindex  ($gycwifimonitordate."-". [:tostr $gycwifimonitortime]);
	:execute {[$gycwifimonitorflood]};
	delay 5s;
	:set ($gycwifimonitorhistoricaltx->$gycwifimonitorcurrentindex) [$gycwifimonitortxbps]
	:set ($gycwifimonitorhistoricalrx->$gycwifimonitorcurrentindex) [$gycwifimonitorrxbps]
	:foreach key,value in=[:pick $gycwifimonitorhistoricaltx 0 1] do={set $gycwifimonitorfirstindex $key};
	if (($gycwifimonitortime>=[:totime [:pick $gycwifimonitorfirstindex 12 30]]) && ($gycwifimonitordate != [:pick $gycwifimonitorfirstindex 0 10])) do={
		:set $gycwifimonitorhistoricaltx [:pick $gycwifimonitorhistoricaltx 1 [:len $gycwifimonitorhistoricaltx]]
		:set $gycwifimonitorhistoricalrx [:pick $gycwifimonitorhistoricalrx 1 [:len $gycwifimonitorhistoricalrx]]
	};
};
# remove existing scripts
/system scheduler remove [find where name~"^Uplink.*"]
# schedule measurement
/system scheduler add name="Uplink measure #1" interval=7m policy=api,ftp,policy,read,sensitive,test,web,write on-event={:set $gycwifimonitorparametershash $gycwifimonitorhugepacketsettings; $gycwifimonitortakemeasure}
/system scheduler add name="Uplink measure #2" interval=13m policy=api,ftp,policy,read,sensitive,test,web,write on-event={:set $gycwifimonitorparametershash $gycwifimonitorhugepacketsettings; $gycwifimonitortakemeasure}
/system scheduler add name="Uplink measure #3" interval=19m policy=api,ftp,policy,read,sensitive,test,web,write on-event={:set $gycwifimonitorparametershash $gycwifimonitorhugepacketsettings; $gycwifimonitortakemeasure}

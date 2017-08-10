:local ntpenabled false;
:set ntpenabled [/system ntp client get enabled];
:if ($ntpenabled != true) do={
	:log info "Recovery: NTP client disabled, enabling.";
	/system ntp client set enabled=yes primary-ntp=[:resolve 0.ru.pool.ntp.org] secondary-ntp=[:resolve 1.ru.pool.ntp.org]
};

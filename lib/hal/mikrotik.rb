module Hal
  class Mikrotik
    # include Skylight::Helpers

    attr_reader :command

    # instrument_method
    def send_command(router, command = nil)
      command ||= @command
      MTik.command(
        host:    router[:ip_name].to_s,
        user:    'admin',
        pass:    router[:admin_password].to_s,
        conn_timeout: 3,
        command: command
      )
    end

    # instrument_method
    def configure(router)
      configs = []
      configs << auto_config(router)
      configs << download_files(router)
      configs << setup_vpn(router)
      configs << setup_dns(router)
      configs << setup_radius(router)
      configs << setup_hotspot(router)
      inputs = []
      inputs << text_input('hotspot_address', 'Hotspot local IP address', 'Configuration details', '192.168.90.1')
      interfaces = []
      interfaces << {
        value: 'wlan1',
        label: 'Wireless connections'
      }
      interfaces << {
        value: 'bridge',
        label: 'Cable connections'
      }
      options = []
      options << {
        name: 'create_admin',
        value: true,
        label: 'Delegate admin account to GYC WiFi'
      }
      options << {
        name: 'run_hotspot',
        value: false,
        label: 'Run hotspot when setup finished'
      }
      inputs << radio_input('hotspot_interface', interfaces, 'wlan1', 'select', 'Hotspot target')
      inputs << checkbox(options, 'switch' 'Hotspot target')
      configuration = {
        configs: configs,
        inputs: inputs
      }
      Rails.logger.debug "configuration: #{configuration.inspect}"
      configuration
    end

    # instrument_method
    def get_reply(router, command = nil)
      command ||= @command
      logger.info "geting replies for command #{command.inspect}".green
      replies = MTik.command(
        host:    router[:ip_name].to_s,
        user:    'admin',
        pass:    router[:admin_password].to_s,
        conn_timeout: 3,
        command: command
      )
      Rails.logger.debug "got replies: #{replies}".green.bold
      result = []
      replies.each do |reply|
        trap = reply.find_sentence('!trap')
        return [trap] if trap
        reply.each { |sentence| result << sentence if sentence.key?('!re') }
      end
      Rails.logger.debug "returning sentences: #{result.inspect}"
      result
    end

    # перед авторизацией нужно сделать /ip hotspot active remove [find where mac=#{mac}]
    # для этого в методе get_client делаем /ip/hotspot/active/print, =.proplist=.id, ?=mac=#{mac}
    # потом смотрим ответ и ищем =.id=....
    # и в методе remove_client делаем /interface/wireless/access-list/remove, =.id=*4EB
    def get_client(mac)
      @command = ['/ip/hotspot/active/print', "?mac-address=#{mac}"]
    end

    def remove_client(id)
      @command = ['/ip/hotspot/active/remove', "=.id=#{id}"]
    end

    def authorize_client(mac, client_ip, username, passwd)
      @command = ['/ip/hotspot/active/login', "=user=#{username}", "=password=#{passwd}",
                  "=mac-address=#{mac}", "=ip=#{client_ip}", '/quit']
    end

    def change_guest_ssid(guest_ssid)
      @command = ['/interface/wireless/set', '=.id=wlan1', "=ssid=#{guest_ssid}", '/quit']
    end

    def change_staff_ssid(staff_ssid)
      @command = ['/interface/wireless/set', '=.id=gyc-staff-wlan', '=disabled=no', "=ssid=#{staff_ssid}", '/quit']
    end

    def change_staff_pass(staff_pass)
      @command = [
        '/interface/wireless/security-profiles/set',
        '=.id=gyc-staff-wlan',
        "=wpa-pre-shared-key=#{staff_pass}",
        "=wpa2-pre-shared-key=#{staff_pass}",
        '=mode=dynamic-keys',
        '=authentication-types=wpa2-psk',
        '/quit'
      ]
    end

    def hotspot_wan_limit(hotspotconnectionlimit)
      @command = ['/ip/hotspot/profile/set', '=.id=gyc-hotspot', "=rate-limit=#{hotspotconnectionlimit}", '/quit']
    end

    def hotspot_wlan_limit(hotspotbalancerlimit)
      @command = ['/ip/hotspot/user/profile/set', '=name=default', "=rate-limit=#{hotspotbalancerlimit}", '/quit']
    end

    # instrument_method
    def radio_input(name, items, selected, style = 'radio', title = '')
      {
        title: title,
        type: 'radio',
        name: name,
        items: items,
        selected: selected,
        style: style
      }
    end

    # instrument_method
    def checkbox(items, style = 'checkbox', title = '')
      {
        title: title,
        type: 'checkbox',
        style: style,
        items: items
      }
    end

    # instrument_method
    def text_input(name, label, title = '', value = '', placeholder = '')
      {
        title: title,
        type: 'text',
        name: name,
        value: value,
        placeholder: placeholder,
        label: label
      }
    end

    # instrument_method
    def auto_config(router)
      fetch = "/tool fetch mode=ftp address=login.gycwifi.com user=#{router[:common_name]} password=#{router[:admin_password]} src-path=flash/%{file} dst-path=flash/%{file}"
      command_set = []
      command_set << format(fetch, file: 'hotspot-ssl.crt')
      command_set << format(fetch, file: 'hotspot-ssl.key')
      command_set << format(fetch, file: 'client.crt')
      command_set << format(fetch, file: 'ca.crt')
      command_set << format(fetch, file: 'lte-reset.rsc')
      command_set << format(fetch, file: 'ntp-reset.rsc')
      command_set << format(fetch, file: 'service/cleanup.rsc')
      command_set << format(fetch, file: 'service/environment.rsc')
      command_set << format(fetch, file: 'service/update.rsc')
      command_set << format(fetch, file: 'service/network-settings.rsc')
      command_set << format(fetch, file: 'service/wireless-settings.rsc')
      command_set << format(fetch, file: 'service/walled-garden.rsc')
      command_set << format(fetch, file: 'service/hotspot-setup.rsc')
      command_set << format(fetch, file: 'service/load-balance.rsc')
      command_set << format(fetch, file: 'service/setup-snmp.rsc')
      command_set << format(fetch, file: 'service/block-wan.rsc')
      command_set << format(fetch, file: 'service/router-settings.rsc')
      command_set << format(fetch, file: 'service/apply-updates.rsc')
      command_set << format(fetch, file: 'service/dns-and-vpn.rsc')
      command_set << format(fetch, file: 'hotspot/alogin.html')
      command_set << format(fetch, file: 'hotspot/common.css')
      command_set << format(fetch, file: 'hotspot/login.html')
      command_set << format(fetch, file: 'hotspot/logout.html')
      command_set << format(fetch, file: 'hotspot/platform.js')
      command_set << format(fetch, file: 'hotspot/md5.js')
      command_set << format(fetch, file: 'hotspot/redirect.html')
      command_set << format(fetch, file: 'hotspot/status.html')
      command_set << format(fetch, file: 'install.rsc')
      command_set << format(fetch, file: 'uplink-monitor.rsc')
      command_set << format(fetch, file: 'ssh_gyc_key.pkey')
      command_set << format(fetch, file: 'client.pem')
      command_set << '/import flash/service/router-settings.rsc'
      command_set << '/import flash/service/environment.rsc'
      command_set << ':global GYCInstallAddScript do={/system script remove [find name=$2]; /system script add source=[/file get [find name=$1] contents] name=$2 owner=admin policy=dude,ftp,password,policy,read,reboot,romon,sensitive,sniff,test,write;};'
      command_set << '$GYCInstallAddScript "flash/service/environment.rsc" $GYCInstallSetEnvironment'
      command_set << '$GYCInstallAddScript "flash/service/router-settings.rsc" $GYCInstallRouterSettings'
      command_set << '$GYCInstallAddScript "flash/service/cleanup.rsc" $GYCInstallCleanup'
      command_set << '$GYCInstallAddScript "flash/service/update.rsc" $GYCInstallUpdate'
      command_set << '$GYCInstallAddScript "flash/lte-reset.rsc" $GYCInstallLTE'
      command_set << '$GYCInstallAddScript "flash/ntp-reset.rsc" $GYCInstallNTP'
      command_set << '$GYCInstallAddScript "flash/gycsetupv2.rsc" $GYCInstallStartup'
      command_set << '$GYCInstallAddScript "flash/service/network-settings.rsc" $GYCInstallNetworkSettings'
      command_set << '$GYCInstallAddScript "flash/service/wireless-settings.rsc" $GYCInstallWirelessSettings'
      command_set << '$GYCInstallAddScript "flash/service/load-balance.rsc" $GYCInstallLoadBalance'
      command_set << '$GYCInstallAddScript "flash/service/hotspot-setup.rsc" $GYCInstallHotspotSetup'
      command_set << '$GYCInstallAddScript "flash/service/setup-snmp.rsc" $GYCInstallSetupSNMP'
      command_set << '$GYCInstallAddScript "flash/service/block-wan.rsc" $GYCInstallBlockWAN'
      command_set << '$GYCInstallAddScript "flash/service/dns-and-vpn.rsc" $GYCInstallDNSVPN'
      command_set << '$GYCInstallScheduleScript $GYCInstallSetEnvironment; /system scheduler set $GYCInstallSetEnvironment start-time=startup on-event=$GYCInstallSetEnvironment;'
      command_set << '$GYCInstallScheduleScript $GYCInstallUpdate; /system scheduler set $GYCInstallUpdate start-time=startup on-event=$GYCInstallUpdate interval=1d;'
      command_set << '$GYCInstallScheduleScript $GYCInstallNTP; /system scheduler set $GYCInstallNTP interval=30s on-event=$GYCInstallNTP start-time=startup;'
      command_set << '$GYCInstallScheduleScript $GYCInstallLTE; /system scheduler set $GYCInstallLTE interval=10m on-event=$GYCInstallLTE;'

      command_set << '/system script run $GYCInstallDNSVPN'
      command_set << '/system script run $GYCInstallSetupSNMP;'
      command_set << '/tool netwatch add host=8.8.8.8 timeout=3s interval=1m up-script="" down-script=$GYCInstallLTE'
      command_set << ':do { /ip dhcp-client add interface="lte1" comment="lte" disabled="no"; /ip firewall nat add chain="srcnat" action="masquerade" out-interface="lte1" comment="lte" disabled="no"; } on-error={ /log error "LTE interface not found"}'
      command_set << '/system script run $GYCInstallNetworkSettings; :if ($GYChotspotBlockServiceAccess) do={ /system script run $GYCInstallBlockWAN }; /system script run $GYCInstallWirelessSettings; :do {/password old-password="" new-password=$GYChotspotAdminPassword confirm-new-password=$GYChotspotAdminPassword;} on-error={ /log error "could not change admin password" }; /system script run $GYCInstallHotspotSetup; /system script run $GYCInstallWalledGarden; /system script run $GYCInstallLoadBalance;'
      command_set << '/user ssh-keys import public-key-file=flash/ssh_gyc_key.pkey user=admin'
      res = []
      command_set.each { |cmd| res << { format: 'ssh', command: "#{cmd}; :put success" } }
      config = {
        name: 'AUTO CONFIGURE',
        config: res
      }
      config
    end

    # instrument_method
    def download_files(router)
      fetch = "/tool fetch mode=ftp address=login.gycwifi.com user=#{router[:common_name]} password=#{router[:admin_password]} src-path=flash/%{file} dst-path=flash/%{file}"
      command_set = []
      command_set << format(fetch, file: 'hotspot-ssl.crt')
      command_set << format(fetch, file: 'hotspot-ssl.key')
      command_set << format(fetch, file: 'client.crt')
      command_set << format(fetch, file: 'ca.crt')
      command_set << format(fetch, file: 'lte-reset.rsc')
      command_set << format(fetch, file: 'ntp-reset.rsc')
      command_set << format(fetch, file: 'service/cleanup.rsc')
      command_set << format(fetch, file: 'service/environment.rsc')
      command_set << format(fetch, file: 'service/update.rsc')
      command_set << format(fetch, file: 'service/network-settings.rsc')
      command_set << format(fetch, file: 'service/wireless-settings.rsc')
      command_set << format(fetch, file: 'service/walled-garden.rsc')
      command_set << format(fetch, file: 'service/hotspot-setup.rsc')
      command_set << format(fetch, file: 'service/load-balance.rsc')
      command_set << format(fetch, file: 'service/setup-snmp.rsc')
      command_set << format(fetch, file: 'service/block-wan.rsc')
      command_set << format(fetch, file: 'service/router-settings.rsc')
      command_set << format(fetch, file: 'service/apply-updates.rsc')
      command_set << format(fetch, file: 'service/dns-and-vpn.rsc')
      command_set << format(fetch, file: 'hotspot/alogin.html')
      command_set << format(fetch, file: 'hotspot/common.css')
      command_set << format(fetch, file: 'hotspot/login.html')
      command_set << format(fetch, file: 'hotspot/logout.html')
      command_set << format(fetch, file: 'hotspot/platform.js')
      command_set << format(fetch, file: 'hotspot/md5.js')
      command_set << format(fetch, file: 'hotspot/redirect.html')
      command_set << format(fetch, file: 'hotspot/status.html')
      command_set << format(fetch, file: 'install.rsc')
      command_set << format(fetch, file: 'uplink-monitor.rsc')
      command_set << format(fetch, file: 'ssh_gyc_key.pkey')
      command_set << format(fetch, file: 'client.pem')
      command_set << '/import flash/service/environment.rsc'
      command_set << '/import flash/service/router-settings.rsc'
      res = []
      command_set.each { |cmd| res << { format: 'ssh', command: "#{cmd}; :put success" } }
      config = {
        name: 'DOWNLOAD FILES',
        config: res
      }
      config
    end

    # instrument_method
    def setup_vpn(_router)
      command_set = []
      command_set << '/import flash/service/environment.rsc'
      command_set << '/import flash/service/router-settings.rsc'
      command_set << '/certificate import file=$GYChotspotClientCertificate passphrase=""'
      command_set << '/certificate import file=$GYChotspotClientKey passphrase="";'
      command_set << '/certificate import file=$GYChotspotCACertificate passphrase="";'
      command_set << '/certificate import file=$GYChotspotSSLCertificate passphrase="";'
      command_set << '/certificate import file=$GYChotspotSSLKey passphrase="";'
      command_set << '/certificate set 0 name=gyc-client-cert;'
      command_set << '/certificate set 1 name=gyc-ca-cert;'
      command_set << '/certificate set [find name="hotspot-ssl.crt_0"] name=gyc-ssl-cert;'
      command_set << '/certificate set [find name="hotspot-ssl.crt_1"] name=gyc-ssl-ca-cert;'
      command_set << '/interface ovpn-client remove [find name=gyc-ovpn-out]'
      command_set << '/interface ovpn-client add name=gyc-ovpn-out connect-to=$GYChotspotVPNServer mode=ip user=$GYChotspotCommonName password="unused" disabled=no certificate=gyc-client-cert auth=sha1 cipher=blowfish128 add-default-route=no profile="default";
      /ip route add dst-address=$GYChotspotRemoteHost gateway=gyc-ovpn-out;'
      res = []
      command_set.each { |cmd| res << { format: 'ssh', command: "#{cmd}; :put success" } }
      config = {
        name: 'SETUP VPN',
        config: res
      }
      config
    end

    # instrument_method
    def setup_dns(_router)
      command_set = []
      command_set << '/import flash/service/environment.rsc'
      command_set << '/import flash/service/router-settings.rsc'
      command_set << '/ip dns static set [find name=vpn.getwifi.com] address=[:resolve $GYChotspotVPNServer];'
      command_set << '/ip dns static set [find name=$GYChotspotVPNServer] address=[:resolve $GYChotspotVPNServer];'
      command_set << '/ip dns static set [find name=login.getwifi.com] address=[:resolve $GYChotspotLoginServer];'
      command_set << '/ip dns static set [find name=$GYChotspotLoginServer] address=[:resolve $GYChotspotLoginServer];'
      command_set << '/ip dns static add name=$GYChotspotLoginServer address=[:resolve $GYChotspotLoginServer];'
      command_set << '/ip dns static add name=$GYChotspotVPNServer address=[:resolve $GYChotspotVPNServer];'
      command_set << '/ip dns static add name=$GYChotspotRouterLocalName address={hotspot_address};'
      command_set << '/ip dns set allow-remote-requests=no;'
      command_set << '/ip dns set servers=$GYChotspotDNSServers;'
      command_set << '/ip dns cache flush;'
      res = []
      command_set.each { |cmd| res << { format: 'ssh', command: "#{cmd}; :put success" } }
      config = {
        name: 'SETUP STATIC DNS',
        config: res
      }
      config
    end

    # instrument_method
    def setup_hotspot(router)
      command_set = []
      command_set << '/import flash/service/environment.rsc'
      command_set << '/import flash/service/router-settings.rsc'
      command_set << '/ip hotspot profile remove [find name=gyc-hotspot]; /ip hotspot profile add copy-from=default name=gyc-hotspot;'
      command_set << '/ip hotspot profile set gyc-hotspot use-radius="yes" login-by="http-pap,https" html-directory=$GYChotspotRoot hotspot-address={$hotspot_address}  dns-name=$GYChotspotRouterLocalName trial-uptime-limit=20s trial-uptime-reset=4s ssl-certificate=gyc-ssl-cert'
      command_set << '/ip service set www-ssl certificate=gyc-ssl-cert disabled=no'
      command_set << '/ip hotspot remove [find name=gyc-login-server];'
      command_set << '/ip hotspot add name=gyc-login-server interface={$hotspot_interface} profile=gyc-hotspot disabled="yes"'
      command_set << "/ip hotspot user profile set default rate-limit=#{router[:wlan]} idle-timeout=1d keepalive-timeout=1d;"
      command_set << "/ip hotspot profile set gyc-hotspot rate-limit=#{router[:wan]};"
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*gycwifi.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="gycwifi.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="gycwifi.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*letsencrypt.org" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*identrust.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*gettwifi.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="gettwifi.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add dst-host="*cootek.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add dst-host="*cootekservice.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add dst-host="54.227.222.192" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add dst-host="54.227.222.192" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add dst-host="delivery.first-impression.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*lkqd.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="lkqd.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*spotxchange.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="spotxchange.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="smaato.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*smaato.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*google-analytics.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*bootstrapcdn.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*googleapis.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*tns-counter.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*pixel.quantserve.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="adnxs.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*adnxs.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="pixel.quantserve.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*aidata.io" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="aidata.io" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*doubleclick.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="doubleclick.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*rubiconproject.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="rubiconproject.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*pubmatic.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="pubmatic.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*insigit.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="insigit.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="95.167.230.210" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="top-fwz1.mail.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*duapps.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="top-fwz1.mail.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*top-fwz1.mail.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="top-fwz1.mail.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*digitaltarget.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="dmg.digitaltarget.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*umengcloud.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="umengcloud.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*taobao.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="taobao.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*mamba.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="mamba.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*rubiconproject.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="rubiconproject.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*rambler.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="rambler.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*republer.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="republer.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*bidswitch.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="bidswitch.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*betweendigital.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="adriver.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*adriver.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="fb.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*fb.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="betweendigital.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*avazutracking.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="avazutracking.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="adhigh.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*adhigh.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="ad-score.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*ad-score.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="quantserve.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*quantserve.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="angsrvr.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*angsrvr.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*facebook.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="facebook.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*akamaihd.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*akamai.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*fbcdn.net" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*vk.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="vk.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*vk.me" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="vk.me" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*twimg.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*twitter.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="twitter.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*odnoklassniki.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="odnoklassniki.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*ok.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="ok.ru" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*mycdn.me" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="mycdn.me" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*instagram.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="instagram.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="*amazonaws.com" server=gyc-login-server;'
      command_set << '/ip hotspot walled-garden add action=allow dst-host="accounts.google.com" server=gyc-login-server;'
      command_set << '/ip hotspot set gyc-login-server disabled={$no_hotspot}'
      res = []
      command_set.each { |cmd| res << { format: 'ssh', command: "#{cmd}; :put success" } }
      config = {
        name: 'SETUP HOTSPOT',
        config: res
      }
      config
    end

    # instrument_method
    def setup_radius(router)
      command_set = []
      command_set << '/import flash/service/environment.rsc'
      command_set << '/import flash/service/router-settings.rsc'
      command_set << "/radius add service=hotspot address=$GYChotspotRemoteHost src-address=#{router[:ip_name]} secret=#{router[:radius_secret]} timeout=6000ms;"
      command_set << 'if {$create_admin} do={/user ssh-keys import public-key-file=flash/ssh_gyc_key.pkey user=admin}'
      res = []
      command_set.each { |cmd| res << { format: 'ssh', command: "#{cmd}; :put success" } }
      config = {
        name: 'SETUP RADIUS CLIENT',
        config: res
      }
      config
    end
  end
end

/log warning "--- Walled farden";
/ip hotspot walled-garden remove [find];
/ip hotspot walled-garden ip remove [ find ];
:do {
    #GYC WiFI;
    /ip hotspot walled-garden add action=allow dst-host="*gycwifi.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="gycwifi.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="${redirect_url}" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*letsencrypt.org" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*identrust.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*gettwifi.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="gettwifi.com" server=gyc-login-server;
    #Login pages external references;
    /ip hotspot walled-garden add dst-host="*cootek.com" server=gyc-login-server;
    /ip hotspot walled-garden add dst-host="*cootekservice.com" server=gyc-login-server;
    /ip hotspot walled-garden add dst-host="54.227.222.192" server=gyc-login-server;
    /ip hotspot walled-garden add dst-host="54.227.222.192" server=gyc-login-server;
    /ip hotspot walled-garden add dst-host="delivery.first-impression.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*lkqd.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="lkqd.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*spotxchange.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="spotxchange.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="smaato.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*smaato.net" server=gyc-login-server;
    #c/ip hotspot walled-garden add action=allow dst-host="*yandex.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*google-analytics.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*bootstrapcdn.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*googleapis.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*tns-counter.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*pixel.quantserve.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="adnxs.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*adnxs.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="pixel.quantserve.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*aidata.io" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="aidata.io" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*doubleclick.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="doubleclick.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*rubiconproject.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="rubiconproject.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*pubmatic.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="pubmatic.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*insigit.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="insigit.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="95.167.230.210" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="top-fwz1.mail.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*duapps.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="top-fwz1.mail.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*top-fwz1.mail.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="top-fwz1.mail.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*digitaltarget.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="dmg.digitaltarget.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*umengcloud.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="umengcloud.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*taobao.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="taobao.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*mamba.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="mamba.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*rubiconproject.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="rubiconproject.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*rambler.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="rambler.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*republer.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="republer.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*bidswitch.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="bidswitch.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*betweendigital.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="adriver.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*adriver.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="fb.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*fb.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="betweendigital.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*avazutracking.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="avazutracking.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="adhigh.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*adhigh.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="ad-score.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*ad-score.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="quantserve.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*quantserve.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="angsrvr.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*angsrvr.com" server=gyc-login-server;


    # Facebook;
    /ip hotspot walled-garden add action=allow dst-host="*facebook.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="facebook.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*akamaihd.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*akamai.net" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*fbcdn.net" server=gyc-login-server;

    # VK;
    /ip hotspot walled-garden add action=allow dst-host="*vk.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="vk.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*vk.me" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="vk.me" server=gyc-login-server;

    # Twitter;
    /ip hotspot walled-garden add action=allow dst-host="*twimg.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*twitter.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="twitter.com" server=gyc-login-server;

    # Odnoklassniki;
    /ip hotspot walled-garden add action=allow dst-host="*odnoklassniki.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="odnoklassniki.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*ok.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="ok.ru" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*mycdn.me" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="mycdn.me" server=gyc-login-server;

    # Instagram;
    /ip hotspot walled-garden add action=allow dst-host="*instagram.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="instagram.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*amazonaws.com" server=gyc-login-server;

    #Google;
    /ip hotspot walled-garden add action=allow dst-host="accounts.google.com" server=gyc-login-server;
    /ip hotspot walled-garden add action=allow dst-host="*fonts.gstatic.com" server=gyc-login-server;

    #Android
    #/ip hotspot walled-garden add action=allow dst-host="*yandex.ru" server=gyc-login-server;
    #/ip hotspot walled-garden add action=allow dst-host="*gstatic.com" server=gyc-login-server;
    #/ip hotspot walled-garden add action=allow dst-host="*android.com" server=gyc-login-server;
    #/ip hotspot walled-garden add action=allow dst-host="*yadro.ru" server=gyc-login-server;
    # Apple iOS captive portal - uncomment if you figured out how to preform seamless auth;
    #/ip hotspot walled-garden add dst-host=*apple.com server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=*apple.com.edgekey.net server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=*akamaiedge.net server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=*akamaitechnologies.com server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=static.ess.apple.com path=/connectivity.txt server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=www.itools.info server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=www.ibook.info server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=www.airport.us server=gyc-login-server;
    #/ip hotspot walled-garden add dst-host=www.thinkdifferent.us server=gyc-login-server;

    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=www.appleiphonecell.com server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=www.itools.info server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=www.ibook.info server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=www.airport.us server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=www.thinkdifferent.us server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=static.ess.apple.com server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=init-p01md.apple.com server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=ess.apple.com server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=apple.com server=gyc-login-server;
    #/ip hotspot walled-garden ip add action=accept disabled=no dst-host=gsp1.apple.com server=gyc-login-server;
    ;
} on-error={ /log error "could not setup walled garden" };

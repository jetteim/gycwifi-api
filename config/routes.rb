# == Route Map
#
#                            Prefix Verb     URI Pattern                                  Controller#Action
#                  dashboard_brands GET      /brands(.:format)                            dashboard/brands#index {:format=>:json}
#                                   POST     /brands(.:format)                            dashboard/brands#create {:format=>:json}
#                   dashboard_brand GET      /brands/:id(.:format)                        dashboard/brands#show {:format=>:json}
#                                   PATCH    /brands/:id(.:format)                        dashboard/brands#update {:format=>:json}
#                                   PUT      /brands/:id(.:format)                        dashboard/brands#update {:format=>:json}
#                                   DELETE   /brands/:id(.:format)                        dashboard/brands#destroy {:format=>:json}
#               dashboard_locations GET      /locations(.:format)                         dashboard/locations#index {:format=>:json}
#                                   POST     /locations(.:format)                         dashboard/locations#create {:format=>:json}
#                dashboard_location GET      /locations/:id(.:format)                     dashboard/locations#show {:format=>:json}
#                                   PATCH    /locations/:id(.:format)                     dashboard/locations#update {:format=>:json}
#                                   PUT      /locations/:id(.:format)                     dashboard/locations#update {:format=>:json}
#                                   DELETE   /locations/:id(.:format)                     dashboard/locations#destroy {:format=>:json}
#                 dashboard_routers GET      /routers(.:format)                           dashboard/routers#index {:format=>:json}
#                                   POST     /routers(.:format)                           dashboard/routers#create {:format=>:json}
#                  dashboard_router GET      /routers/:id(.:format)                       dashboard/routers#show {:format=>:json}
#                                   PATCH    /routers/:id(.:format)                       dashboard/routers#update {:format=>:json}
#                                   PUT      /routers/:id(.:format)                       dashboard/routers#update {:format=>:json}
#                                   DELETE   /routers/:id(.:format)                       dashboard/routers#destroy {:format=>:json}
#                 dashboard_clients GET      /clients(.:format)                           dashboard/clients#index {:format=>:json}
#                                   POST     /clients(.:format)                           dashboard/clients#create {:format=>:json}
#                  dashboard_client GET      /clients/:id(.:format)                       dashboard/clients#show {:format=>:json}
#                                   PATCH    /clients/:id(.:format)                       dashboard/clients#update {:format=>:json}
#                                   PUT      /clients/:id(.:format)                       dashboard/clients#update {:format=>:json}
#                                   DELETE   /clients/:id(.:format)                       dashboard/clients#destroy {:format=>:json}
#             dashboard_social_logs GET      /social_logs(.:format)                       dashboard/social_logs#index {:format=>:json}
#                                   POST     /social_logs(.:format)                       dashboard/social_logs#create {:format=>:json}
#              dashboard_social_log GET      /social_logs/:id(.:format)                   dashboard/social_logs#show {:format=>:json}
#                                   PATCH    /social_logs/:id(.:format)                   dashboard/social_logs#update {:format=>:json}
#                                   PUT      /social_logs/:id(.:format)                   dashboard/social_logs#update {:format=>:json}
#                                   DELETE   /social_logs/:id(.:format)                   dashboard/social_logs#destroy {:format=>:json}
#                 dashboard_layouts GET      /layouts(.:format)                           dashboard/layouts#index {:format=>:json}
#                                   POST     /layouts(.:format)                           dashboard/layouts#create {:format=>:json}
#                  dashboard_layout GET      /layouts/:id(.:format)                       dashboard/layouts#show {:format=>:json}
#                                   PATCH    /layouts/:id(.:format)                       dashboard/layouts#update {:format=>:json}
#                                   PUT      /layouts/:id(.:format)                       dashboard/layouts#update {:format=>:json}
#                                   DELETE   /layouts/:id(.:format)                       dashboard/layouts#destroy {:format=>:json}
#                   dashboard_users GET      /users(.:format)                             dashboard/users#index {:format=>:json}
#                                   POST     /users(.:format)                             dashboard/users#create {:format=>:json}
#                    dashboard_user GET      /users/:id(.:format)                         dashboard/users#show {:format=>:json}
#                                   PATCH    /users/:id(.:format)                         dashboard/users#update {:format=>:json}
#                                   PUT      /users/:id(.:format)                         dashboard/users#update {:format=>:json}
#                                   DELETE   /users/:id(.:format)                         dashboard/users#destroy {:format=>:json}
#                    dashboard_vips GET      /vips(.:format)                              dashboard/vips#index {:format=>:json}
#                                   POST     /vips(.:format)                              dashboard/vips#create {:format=>:json}
#                     dashboard_vip GET      /vips/:id(.:format)                          dashboard/vips#show {:format=>:json}
#                                   PATCH    /vips/:id(.:format)                          dashboard/vips#update {:format=>:json}
#                                   PUT      /vips/:id(.:format)                          dashboard/vips#update {:format=>:json}
#                                   DELETE   /vips/:id(.:format)                          dashboard/vips#destroy {:format=>:json}
#                                   GET      /polls/:poll_id/:answer_id/clients(.:format) dashboard/surveys/surveys/stats#clients {:format=>:json}
#           dashboard_surveys_polls GET      /polls(.:format)                             dashboard/surveys/polls#index {:format=>:json}
#                                   POST     /polls(.:format)                             dashboard/surveys/polls#create {:format=>:json}
#            dashboard_surveys_poll GET      /polls/:id(.:format)                         dashboard/surveys/polls#show {:format=>:json}
#                                   PATCH    /polls/:id(.:format)                         dashboard/surveys/polls#update {:format=>:json}
#                                   PUT      /polls/:id(.:format)                         dashboard/surveys/polls#update {:format=>:json}
#                                   DELETE   /polls/:id(.:format)                         dashboard/surveys/polls#destroy {:format=>:json}
#        dashboard_surveys_attempts GET      /attempts(.:format)                          dashboard/surveys/attempts#index {:format=>:json}
#                                   POST     /attempts(.:format)                          dashboard/surveys/attempts#create {:format=>:json}
#         dashboard_surveys_attempt GET      /attempts/:id(.:format)                      dashboard/surveys/attempts#show {:format=>:json}
#                                   PATCH    /attempts/:id(.:format)                      dashboard/surveys/attempts#update {:format=>:json}
#                                   PUT      /attempts/:id(.:format)                      dashboard/surveys/attempts#update {:format=>:json}
#                                   DELETE   /attempts/:id(.:format)                      dashboard/surveys/attempts#destroy {:format=>:json}
#           dashboard_export_to_amo GET      /export_to_amo(.:format)                     dashboard/clients#export_to_amo {:format=>:json}
#     dashboard_export_to_mailchimp GET      /export_to_mailchimp(.:format)               dashboard/clients#export_to_mailchimp {:format=>:json}
#   dashboard_email_congratulations POST     /email_congratulations(.:format)             dashboard/clients#email_congratulations {:format=>:json}
#     dashboard_sms_congratulations POST     /sms_congratulations(.:format)               dashboard/clients#sms_congratulations {:format=>:json}
#        dashboard_request_password POST     /request_password(.:format)                  dashboard/users#request_password {:format=>:json}
#                    dashboard_lang POST     /lang(.:format)                              dashboard/users#lang {:format=>:json}
#    dashboard_stats_locations_list GET      /stats/locations_list(.:format)              dashboard/stats#locations_list {:format=>:json}
#    dashboard_stats_authorizations GET      /stats/authorizations(.:format)              dashboard/stats#authorizations {:format=>:json}
#      dashboard_stats_all_connects GET      /stats/all_connects(.:format)                dashboard/stats#all_connects {:format=>:json}
#   dashboard_stats_social_connects GET      /stats/social_connects(.:format)             dashboard/stats#social_connects {:format=>:json}
# dashboard_stats_new_old_users_pie GET      /stats/new_old_users_pie(.:format)           dashboard/stats#new_old_users_pie {:format=>:json}
#          dashboard_stats_time_pie GET      /stats/time_pie(.:format)                    dashboard/stats#time_pie {:format=>:json}
#        dashboard_stats_social_pie GET      /stats/social_pie(.:format)                  dashboard/stats#social_pie {:format=>:json}
#      dashboard_stats_visitors_pie GET      /stats/visitors_pie(.:format)                dashboard/stats#visitors_pie {:format=>:json}
#       dashboard_stats_questionpie GET      /stats/questionpie(.:format)                 dashboard/stats#questionpie {:format=>:json}
#           dashboard_stats_age_pie GET      /stats/age_pie(.:format)                     dashboard/stats#age_pie {:format=>:json}
#        dashboard_stats_gender_pie GET      /stats/gender_pie(.:format)                  dashboard/stats#gender_pie {:format=>:json}
#     dashboard_stats_new_old_users GET      /stats/new_old_users(.:format)               dashboard/stats#new_old_users {:format=>:json}
#     dashboard_stats_clients_count GET      /stats/clients_count(.:format)               dashboard/stats#clients_count {:format=>:json}
#     dashboard_public_stats_totals GET      /public_stats/totals(.:format)               dashboard/stats#public_all_connects {:format=>:json}
#       dashboard_public_stats_time GET      /public_stats/time(.:format)                 dashboard/stats#public_time_pie {:format=>:json}
#     dashboard_public_stats_social GET      /public_stats/social(.:format)               dashboard/stats#public_social_pie {:format=>:json}
#        dashboard_public_stats_age GET      /public_stats/age(.:format)                  dashboard/stats#public_age_pie {:format=>:json}
#   dashboard_public_stats_visitors GET      /public_stats/visitors(.:format)             dashboard/stats#public_visitors_pie {:format=>:json}
#         dashboard_manage_accounts GET      /manage/accounts(.:format)                   dashboard/users#accounts {:format=>:json}
#            dashboard_manage_users GET      /manage/users(.:format)                      dashboard/users#users {:format=>:json}
#           dashboard_manage_brands GET      /manage/brands(.:format)                     dashboard/users#brands {:format=>:json}
#          dashboard_manage_routers GET      /manage/routers(.:format)                    dashboard/users#routers {:format=>:json}
#        dashboard_manage_locations GET      /manage/locations(.:format)                  dashboard/users#locations {:format=>:json}
#         dashboard_payment_success POST     /payment/success(.:format)                   dashboard/payments#success {:format=>:json}
#           dashboard_payment_error POST     /payment/error(.:format)                     dashboard/payments#error {:format=>:json}
#              api_authorize_client POST     /authorize_client(.:format)                  api/v1/hal#authorize_client {:format=>:json}
#                     api_close_cna POST     /close_cna(.:format)                         api/v1/hal#close_cna {:format=>:json}
#             api_change_guest_ssid POST     /change_guest_ssid(.:format)                 api/v1/hal#change_guest_ssid {:format=>:json}
#             api_change_staff_ssid POST     /change_staff_ssid(.:format)                 api/v1/hal#change_staff_ssid {:format=>:json}
#             api_change_staff_pass POST     /change_staff_pass(.:format)                 api/v1/hal#change_staff_pass {:format=>:json}
#             api_hotspot_wan_limit POST     /hotspot_wan_limit(.:format)                 api/v1/hal#hotspot_wan_limit {:format=>:json}
#            api_hotspot_wlan_limit POST     /hotspot_wlan_limit(.:format)                api/v1/hal#hotspot_wlan_limit {:format=>:json}
#                      api_opinions GET      /opinions(.:format)                          api/v1/opinions#index {:format=>:json}
#                                   POST     /opinions(.:format)                          api/v1/opinions#create {:format=>:json}
#                       api_opinion GET      /opinions/:id(.:format)                      api/v1/opinions#show {:format=>:json}
#                                   PATCH    /opinions/:id(.:format)                      api/v1/opinions#update {:format=>:json}
#                                   PUT      /opinions/:id(.:format)                      api/v1/opinions#update {:format=>:json}
#                                   DELETE   /opinions/:id(.:format)                      api/v1/opinions#destroy {:format=>:json}
#    login_receive_data_from_router GET      /receive_data_from_router(.:format)          login/auth#location_style {:format=>:json}
#                                   POST     /receive_data_from_router(.:format)          login/auth#location_style {:format=>:json}
#         login_check_client_number GET      /check_client_number(.:format)               login/phone#check_client_number {:format=>:json}
#                                   POST     /check_client_number(.:format)               login/phone#check_client_number {:format=>:json}
#           login_pending_call_auth GET      /pending_call_auth(.:format)                 login/phone#pending_call_auth {:format=>:json}
#                                   POST     /pending_call_auth(.:format)                 login/phone#pending_call_auth {:format=>:json}
#                 login_verify_code GET      /verify_code(.:format)                       login/phone#verify_code {:format=>:json}
#                                   POST     /verify_code(.:format)                       login/phone#verify_code {:format=>:json}
#    login_client_call_confirmation GET      /client_call_confirmation(.:format)          login/phone#client_call_confirmation {:format=>:json}
#                                   POST     /client_call_confirmation(.:format)          login/phone#client_call_confirmation {:format=>:json}
#         login_login_session_style GET      /login_session_style(.:format)               login/phone#login_session_style {:format=>:json}
#                                   POST     /login_session_style(.:format)               login/phone#login_session_style {:format=>:json}
#        login_login_session_router GET      /login_session_router(.:format)              login/phone#login_session_router {:format=>:json}
#                                   POST     /login_session_router(.:format)              login/phone#login_session_router {:format=>:json}
#           login_login_session_css GET      /login_session_css(.:format)                 login/phone#login_session_css {:format=>:json}
#                                   POST     /login_session_css(.:format)                 login/phone#login_session_css {:format=>:json}
#     login_login_session_targeting GET      /login_session_targeting(.:format)           login/phone#login_session_targeting {:format=>:json}
#                                   POST     /login_session_targeting(.:format)           login/phone#login_session_targeting {:format=>:json}
#          login_login_session_poll GET      /login_session_poll(.:format)                login/phone#login_session_poll {:format=>:json}
#                                   POST     /login_session_poll(.:format)                login/phone#login_session_poll {:format=>:json}
#        login_login_session_client GET      /login_session_client(.:format)              login/phone#login_session_client {:format=>:json}
#                                   POST     /login_session_client(.:format)              login/phone#login_session_client {:format=>:json}
#           login_send_poll_results GET      /send_poll_results(.:format)                 login/auth#poll_results {:format=>:json}
#                                   POST     /send_poll_results(.:format)                 login/auth#poll_results {:format=>:json}
#                            upload POST     /upload(.:format)                            uploads#recieve_file
#                                   GET|POST /auth/:provider(.:format)                    auth#authenticate
#                    without_social POST     /without_social(.:format)                    auth#without_social
#                                   GET      /without_social(.:format)                    auth#without_social
#

Rails.application.routes.draw do
  # Dashboard part
  namespace :dashboard, defaults: { format: :json },
                        constraints: { subdomain: /api.*/ }, path: '/' do
    resources :brands
    resources :login_menu_items
    resources :clients
    resources :locations
    resources :layouts
    resources :notifications
    resources :opinions
    resources :promo_codes, only: %i[index create]
    resources :rewards, only: %i[index]
    resources :referrals, only: %i[index]
    resources :routers do
      member do
        get 'package'
      end
    end
    resources :social_logs
    namespace :surveys, path: '/' do
      resources :polls do
        # member do
        get '/:answer_id/clients', to: 'stats#clients'
        get '/activity', to: 'stats#activity'
        get '/export_to_xlsx', to: 'polls#export_to_xlsx'
        # end
      end
      resources :attempts
    end
    resources :users
    resources :vips
    resources :vouchers

    get '/opinion_rating',          to: 'opinions#opinion_rating'
    # Exports
    get '/export_to_amo',       to: 'clients#export_to_amo'
    get '/export_to_mailchimp', to: 'clients#export_to_mailchimp'

    # Congratulations
    post '/email_congratulations', to: 'clients#email_congratulations'
    post '/sms_congratulations',   to: 'clients#sms_congratulations'

    # Request password
    post '/request_password', to: 'users#request_password'

    # Access rights
    # get '/check_access_rights', to: 'dashboard/users#check_access_rights'

    # Change language
    post '/lang', to: 'users#lang', as: :lang
    get '/unread_count', to: 'notifications#unread_count'

    # Stats part
    get '/stats/locations_list',    to: 'stats#locations_list'
    get '/stats/authorizations',    to: 'stats#authorizations'
    get '/stats/all_connects',      to: 'stats#all_connects'
    get '/stats/social_connects',   to: 'stats#social_connects'
    get '/stats/new_old_users_pie', to: 'stats#new_old_users_pie'
    get '/stats/time_pie',          to: 'stats#time_pie'
    get '/stats/social_pie',        to: 'stats#social_pie'
    get '/stats/visitors_pie',      to: 'stats#visitors_pie'
    get '/stats/questionpie',       to: 'stats#questionpie'
    get '/stats/age_pie',           to: 'stats#age_pie'
    get '/stats/gender_pie',        to: 'stats#gender_pie'
    get '/stats/new_old_users',     to: 'stats#new_old_users'
    get '/stats/clients_count',     to: 'stats#clients_count'
    get '/stats/poll_activity',     to: 'stats#poll_activity'
    get '/public_stats/totals',     to: 'public_stats#all_connections'
    get '/public_stats/time',       to: 'public_stats#time_pie'
    get '/public_stats/social',     to: 'public_stats#social_pie'
    get '/public_stats/age',        to: 'public_stats#age_pie'
    get '/public_stats/visitors',   to: 'public_stats#visitors_pie'
    # manage part
    get '/manage/accounts',         to: 'users#accounts'
    get '/manage/users',            to: 'users#users'
    get '/manage/brands',           to: 'users#brands'
    get '/manage/routers',          to: 'users#routers'
    get '/manage/locations',        to: 'users#locations'
    # Payment part
    post '/payment/success',        to: 'payments#success'
    post '/payment/error',          to: 'payments#error'
  end

  # Hulk part
  namespace :api, defaults: { format: :json },
                  constraints: { subdomain: /.*a.*/ }, path: '/' do

    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      post 'availability_check', to: 'hal#availability_check'
      post 'authorize_client', to: 'hal#authorize_client'
      get 'authorize_client', to: 'hal#authorize_client'
      post 'close_cna', to: 'hal#close_cna'
      get 'close_cna', to: 'hal#close_cna'
      post 'change_guest_ssid', to: 'hal#change_guest_ssid'
      get 'change_guest_ssid', to: 'hal#change_guest_ssid'
      post 'change_staff_ssid', to: 'hal#change_staff_ssid'
      get 'change_staff_ssid', to: 'hal#change_staff_ssid'
      post 'change_staff_pass', to: 'hal#change_staff_pass'
      get 'change_staff_pass', to: 'hal#change_staff_pass'
      post 'hotspot_wan_limit', to: 'hal#hotspot_wan_limit'
      get 'hotspot_wan_limit', to: 'hal#hotspot_wan_limit'
      post 'hotspot_wlan_limit', to: 'hal#hotspot_wlan_limit'
      get 'hotspot_wlan_limit', to: 'hal#hotspot_wlan_limit'
      post 'configure', to: 'hal#configure'
      get 'configure', to: 'hal#configure'
    end
  end

  # Login part
  namespace :login, defaults: { format: :json },
                    constraints: { subdomain: /api.*/ }, path: '/' do

    post 'availability_check', to: 'phone#availability_check'

    get '/receive_data_from_router', to: 'auth#location_style'
    post '/receive_data_from_router', to: 'auth#location_style'

    get '/check_client_number', to: 'phone#check_client_number'
    post '/check_client_number', to: 'phone#check_client_number'

    get '/pending_call_auth', to: 'phone#pending_call_auth'
    post '/pending_call_auth', to: 'phone#pending_call_auth'

    get '/verify_code', to: 'phone#verify_code'
    post '/verify_code', to: 'phone#verify_code'

    get '/client_call_confirmation', to: 'phone#client_call_confirmation'
    post '/client_call_confirmation', to: 'phone#client_call_confirmation'

    get '/login_session_style', to: 'phone#login_session_style'
    post '/login_session_style', to: 'phone#login_session_style'

    get '/login_session_router', to: 'phone#login_session_router'
    post '/login_session_router', to: 'phone#login_session_router'

    get '/login_session_css', to: 'phone#login_session_css'
    post '/login_session_css', to: 'phone#login_session_css'

    get '/login_session_targeting', to: 'phone#login_session_targeting'
    post '/login_session_targeting', to: 'phone#login_session_targeting'

    get '/login_session_poll', to: 'phone#login_session_poll'
    post '/login_session_poll', to: 'phone#login_session_poll'

    get '/login_session_client', to: 'phone#login_session_client'
    post '/login_session_client', to: 'phone#login_session_client'

    get '/send_poll_results', to: 'auth#poll_results'
    post '/send_poll_results', to: 'auth#poll_results'
  end

  # ======= Other routes =======

  # Uploads
  post '/upload', to: 'uploads#recieve_file'

  # Auth
  match '/auth/:provider', to: 'auth#authenticate', via: %i[get post],
                           constraints: { subdomain: /api.*/ }
  match '/auth/:provider', to: 'auth#authenticate', via: %i[get],
                           constraints: { subdomain: /dashboard.*|login.*/ }
  # post '/without_social',   to: 'auth#without_social'
  # get  '/without_social',   to: 'auth#without_social'
  # post '/voucher',   to: 'auth#voucher'
  # get  '/voucher',   to: 'auth#voucher'
  # CORS
  match '*any' => 'application#options', :via => [:options]
end

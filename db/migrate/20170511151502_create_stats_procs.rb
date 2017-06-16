class CreateStatsProcs < ActiveRecord::Migration[5.0]
  def change
    # ClientsAccountingData model
    connection.execute("
    CREATE OR REPLACE FUNCTION public.clients_page(userid integer)
     RETURNS character varying
     LANGUAGE plpgsql
    AS $function$declare
            clients_page varchar;
            line varchar;
            users cursor for select role_cd = 3 as isadmin from users where id = userid; isadmin boolean;
            clients cursor for select distinct id, phone_number from clients where not phone_number is null;
            clients_filtered cursor for select distinct clients.id, clients.phone_number from clients join social_accounts on clients.id = social_accounts.client_id where not (clients.phone_number is null) and social_accounts.id in (select social_account_id from social_logs where location_id in (select id from locations where user_id = userid));
            clientid integer;
            client_updated cursor for select max(updated_at) from social_accounts where client_id = clientid; updatedat timestamp;
            social_accounts_image cursor for select image from social_accounts where client_id = clientid and not image is null order by updated_at desc LIMIT 1; clientimage varchar;
            social_accounts_username cursor for select username from social_accounts where client_id = clientid and not username is null order by updated_at desc LIMIT 1; clientusername varchar;
            social_accounts_email cursor for select email from social_accounts where client_id = clientid and not email is null order by updated_at desc LIMIT 1; clientemail varchar;
            social_accounts_gender cursor for select gender from social_accounts where client_id = clientid and not gender is null order by updated_at desc LIMIT 1; clientgender varchar;
            social_accounts_provider cursor for select provider from social_accounts where client_id = clientid and not provider is null order by updated_at desc LIMIT 1; clientprovider varchar;
            social_accounts_profile cursor for select profile from social_accounts where client_id = clientid and not profile is null order by updated_at desc LIMIT 1; clientprofile varchar;
            social_accounts_visits cursor for select count(id) as visits from social_logs where social_account_id in (select id from social_accounts where client_id = clientid); clientvisits integer; visits integer;
            social_accounts_visits_30 cursor for select count(id) as visits30 from social_logs where social_account_id in (select id from social_accounts where client_id = clientid) and created_at > current_date - interval '30 days'; clientvisits30 integer; visits30 integer;

          begin
    	    open users; fetch users into isadmin;close users;
    	    clients_page = '';
            if isadmin then
              for client in clients loop
                execute pg_sleep(0.01);
          	    clientid = client.id;
          	    select image into clientimage from social_accounts where client_id = clientid and not image is null order by updated_at desc LIMIT 1;
                select max(updated_at) into updatedat from social_logs where social_account_id in (select id from social_accounts where client_id = clientid);
          	    select username into clientusername from social_accounts where client_id = clientid and not username is null order by updated_at desc LIMIT 1;
                select email into clientemail from social_accounts where client_id = clientid and not email is null order by updated_at desc LIMIT 1;
                select gender into clientgender from social_accounts where client_id = clientid and not gender is null order by updated_at desc LIMIT 1;
                select provider into clientprovider from social_accounts where client_id = clientid and not provider is null order by updated_at desc LIMIT 1;
                select profile into clientprofile from social_accounts where client_id = clientid and not profile is null order by updated_at desc LIMIT 1;
                select count(id) into visits from social_logs where social_account_id in (select id from social_accounts where client_id = clientid);
                select count(id) into visits30 from social_logs where social_account_id in (select id from social_accounts where client_id = clientid) and created_at > current_date - interval '30 days';
                line = format('{\"image\": \"%s\", \"phone_number\": \"%s\", \"email\": \"%s\", \"username\": \"%s\", \"visits\": \"%s\", \"visits30\": \"%s\", \"updated_at\": \"%s\", \"gender\": \"%s\", \"provider\": \"%s\", \"profile\": \"%s\"}',
                  clientimage,
                  client.phone_number,
                  clientemail,
                  clientusername,
                  to_char(visits, '00000'),
                  to_char(visits30, '00000'),
                  updatedat::date,
                  clientgender,
                  clientprovider,
                  clientprofile
                );
                --raise notice 'line=%', line;
                clients_page = clients_page || line || ', ';
                --raise notice 'result=%', clients_page;
          	  end loop;
            else
              for client in clients_filtered loop
                execute pg_sleep(0.01);
          	    clientid = client.id;
          	    select image into clientimage from social_accounts where client_id = clientid and not image is null order by updated_at desc LIMIT 1;
                select max(updated_at) into updatedat from social_logs where social_account_id in (select id from social_accounts where client_id = clientid);
          	    select username into clientusername from social_accounts where client_id = clientid and not username is null order by updated_at desc LIMIT 1;
                select email into clientemail from social_accounts where client_id = clientid and not email is null order by updated_at desc LIMIT 1;
                select gender into clientgender from social_accounts where client_id = clientid and not gender is null order by updated_at desc LIMIT 1;
                select provider into clientprovider from social_accounts where client_id = clientid and not provider is null order by updated_at desc LIMIT 1;
                select profile into clientprofile from social_accounts where client_id = clientid and not profile is null order by updated_at desc LIMIT 1;
                select count(id) into visits from social_logs where social_account_id in (select id from social_accounts where client_id = clientid);
                select count(id) into visits30 from social_logs where social_account_id in (select id from social_accounts where client_id = clientid) and created_at > current_date - interval '30 days';
                line = format('{\"image\": \"%s\", \"phone_number\": \"%s\", \"email\": \"%s\", \"username\": \"%s\", \"visits\": \"%s\", \"visits30\": \"%s\", \"updated_at\": \"%s\", \"gender\": \"%s\", \"provider\": \"%s\", \"profile\": \"%s\"}',
                  clientimage,
                  client.phone_number,
                  clientemail,
                  clientusername,
                  to_char(visits, '00000'),
                  to_char(visits30, '00000'),
                  updatedat::date,
                  clientgender,
                  clientprovider,
                  clientprofile
                );
                --raise notice 'line=%', line;
                clients_page = clients_page || line || ', ';
                --raise notice 'result=%', clients_page;
          	  end loop;
            end if;
            return clients_page;
          end;$function$

    ;
    drop index if exists clients_pages_id;
    drop materialized view if exists clients_pages;
    create materialized view clients_pages as select users.id as id, users.id as user_id, clients_page(users.id) as clients_page from users;
    create unique index clients_pages_id on clients_pages (id);

    CREATE OR REPLACE FUNCTION public.refresh_statistics(userid integer)
     RETURNS character varying
     LANGUAGE plpgsql
    AS $function$declare
      fusers cursor for select id from users;
      viewname varchar;
    begin
    	execute 'refresh materialized view CONCURRENTLY clients_pages';
      return '';
    end;$function$
;")
  end
end

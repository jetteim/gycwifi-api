class ChangeAmocrmexportFun < ActiveRecord::Migration[5.0]
  def change
    connection.execute("
    CREATE OR REPLACE FUNCTION public.amocrmexport(userid integer)
     RETURNS character varying
     LANGUAGE plpgsql
    AS $function$declare
        amocrm varchar := e'\xEF\xBB\xBFEmail, Name, Phone \n';
        line varchar;
        users cursor for select type='AdminUser' as isadmin from users where id = userid;
        isadmin boolean;
        clients cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name,coalesce(phone_number,'') as phone from clients join social_accounts on clients.id = social_accounts.client_id where not (clients.phone_number is null and social_accounts.email is null);
        clients_filtered cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name,coalesce(phone_number,'') as phone from clients join social_accounts on clients.id = social_accounts.client_id where not (clients.phone_number is null and social_accounts.email is null) and social_accounts.id in (select social_account_id from social_logs where location_id in (select id from locations where user_id = userid));
      begin
        open users; fetch users into isadmin;
        if isadmin then
          for client in clients loop
            line = format('%s, %s, %s',client.email,client.name,client.phone);
            --raise notice 'result=%', line;
            amocrm = amocrm || line || e'\n';
          end loop;
        else
          for client in clients_filtered loop
            line = format('%s, %s, %s',client.email,client.name,client.phone);
            --raise notice 'result=%', line;
            amocrm = amocrm || line || e'\n';
          end loop;
        end if;
        return amocrm;
      end;$function$")
  end
end

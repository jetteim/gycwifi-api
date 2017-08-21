class ChangeMailchimpexportFun < ActiveRecord::Migration[5.0]
  def change
    connection.execute("
    CREATE OR REPLACE FUNCTION public.mailchimpexport(userid integer)
     RETURNS character varying
     LANGUAGE plpgsql
    AS $function$declare
        mailchimp varchar := e'\xEF\xBB\xBFEmail, Name\n';
        line varchar;
        users cursor for select type='AdminUser' as isadmin from users where id = userid;
        isadmin boolean;
        social_accounts cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name from social_accounts where not (social_accounts.email is null);
        social_accounts_filtered cursor for select distinct coalesce(email,'') as email,coalesce(username,'') as name from social_accounts where not (social_accounts.email is null) and social_accounts.id in (select social_account_id from social_logs where location_id in (select id from locations where user_id = userid));
      begin
        open users; fetch users into isadmin;
        if isadmin then
          for client in social_accounts loop
            line = format('%s, %s',client.email,client.name);
            --raise notice 'result=%', line;
            mailchimp = mailchimp || line || e'\n';
          end loop;
        else
          for client in social_accounts_filtered loop
            line = format('%s, %s',client.email,client.name);
            --raise notice 'result=%', line;
            mailchimp = mailchimp || line || e'\n';
          end loop;
        end if;
        return mailchimp;
      end;$function$")
  end
end

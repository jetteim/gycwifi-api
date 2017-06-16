class AddVisitsView < ActiveRecord::Migration[5.0]
  def change
    # ClientsAccountingData model
    connection.execute("
    drop view if exists clients_visits;
    drop view if exists client_visits;
    create view client_visits as
    select social_logs.location_id, clients.id as client_id, count(client_id)
    from social_logs join social_accounts on social_logs.social_account_id = social_accounts.id
    join clients on social_accounts.client_id = clients.id
    group by location_id, clients.id;
    drop view if exists traffic_report;
    drop view if exists traffic_data;
    create view traffic_datas as
      select callingstationid as mac, username,
      nasipaddress as ip_name, created_at,
      acctstoptime as last_seen,
    sum(acctsessiontime) as total_time,
    sum(acctinputoctets) as outgoing_bytes,
    sum(acctoutputoctets) as  incoming_bytes
    from client_accounting_logs where not (connectinfo_stop is null) group by mac, username, nasipaddress, created_at, acctstoptime;
    create view traffic_reports as
      SELECT mac, ip_name,
      max(created_at) as last_login,
      max(last_seen) as last_logout,
      sum(total_time) as total_time,
      sum(outgoing_bytes) as outgoing_bytes,
      sum(incoming_bytes) as incoming_bytes
      FROM public.traffic_datas
      group by mac, ip_name")
  end
end

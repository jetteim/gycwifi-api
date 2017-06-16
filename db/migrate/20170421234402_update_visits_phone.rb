class UpdateVisitsPhone < ActiveRecord::Migration[5.0]
  def change
    # ClientsAccountingData model
    connection.execute("
    drop view if exists client_visits;
    create view client_visits as
    select social_logs.location_id, clients.id as client_id, clients.phone_number as phone_number, max(social_logs.updated_at) as updated_at, count(client_id) as visits
from social_logs join social_accounts on social_logs.social_account_id = social_accounts.id
join clients on social_accounts.client_id = clients.id
where not phone_number is null
group by location_id, clients.id, clients.phone_number;")
  end
end

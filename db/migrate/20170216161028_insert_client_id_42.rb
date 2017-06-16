class InsertClientId42 < ActiveRecord::Migration[5.0]
  def change
    execute 'delete from clients where id=42;'
    execute "INSERT INTO public.clients (id, phone_number, created_at, updated_at) VALUES(42, '9876543210', now(), now());"
  end
end

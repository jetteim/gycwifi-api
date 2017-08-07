class CreateAgentPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :agent_payment_methods do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end

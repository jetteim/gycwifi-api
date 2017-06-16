class CreateAttempts < ActiveRecord::Migration[5.0]
  def change
    create_table :attempts do |t|
      t.integer :interview_id
      t.integer :poll_id
      t.integer :client_id
      t.integer :question_id
      t.integer :answer_id

      t.timestamps
    end
  end
end

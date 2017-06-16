class AddInterviewUuidColumnToAttempts < ActiveRecord::Migration[5.0]
  def change
    add_column :attempts, :interview_uuid, :integer
  end
end

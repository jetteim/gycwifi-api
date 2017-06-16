class RemoveColumnInterviewIdFromAttempts < ActiveRecord::Migration[5.0]
  def change
    remove_column :attempts, :interview_id, :integer
  end
end

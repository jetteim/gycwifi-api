class RemovePollIdAndQuestionIdColumnFromAttempts < ActiveRecord::Migration[5.0]
  def change
    remove_column :attempts, :poll_id, :integer
    remove_column :attempts, :question_id, :integer
  end
end

class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :title
      t.string :question_type
      t.belongs_to :poll

      t.timestamps
    end
  end
end

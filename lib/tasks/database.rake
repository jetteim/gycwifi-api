namespace :db do
  desc 'Correction of sequences id'
  task correction_seq_id: :environment do
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
  desc 'Sync production -> staging databases'
  task sync: :environment do
    # p `ls -axl`
    `cd ../infrastructure/db-replicaton/ && rubyrep sync -c new-stg-from-prod.rb` if Rails.env.staging?
  end
end

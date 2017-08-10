class ConvertSocialAccountsProviderToEnum < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE social_provider
      AS ENUM (
        'password', 'google_oauth2', 'vk', 'facebook', 'twitter', 'instagram',
        'odnoklassniki'
      );

      ALTER TABLE social_accounts
      ALTER COLUMN provider
      TYPE social_provider
      USING provider::social_provider;
    SQL
  end

  def down
    change_column :social_accounts, :provider, :string

    execute 'DROP TYPE social_provider;'
  end
end

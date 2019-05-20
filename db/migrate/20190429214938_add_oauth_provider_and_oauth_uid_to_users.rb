class AddOauthProviderAndOauthUidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :oauth_provider, :string
    add_column :users, :oauth_uid, :integer
  end
end

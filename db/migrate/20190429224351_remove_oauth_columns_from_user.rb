class RemoveOauthColumnsFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :oauth_provider
    remove_column :users, :oauth_uid
  end
end

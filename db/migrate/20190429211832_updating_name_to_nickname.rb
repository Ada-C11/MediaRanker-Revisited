class UpdatingNameToNickname < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :name, :nickname
  end
end

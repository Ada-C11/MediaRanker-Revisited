class DropAddNameEmailUsers < ActiveRecord::Migration[5.2]
  def change
    drop_table :add_name_and_email_to_users
  end
end

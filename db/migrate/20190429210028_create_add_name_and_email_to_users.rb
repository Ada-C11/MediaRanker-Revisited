class CreateAddNameAndEmailToUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :add_name_and_email_to_users do |t|

      t.timestamps
    end
  end
end

class AddForeignKeyUserToWork < ActiveRecord::Migration[5.2]
  def change
    add_reference :works, :user, index: true
  end
end

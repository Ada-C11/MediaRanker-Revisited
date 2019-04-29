class AddNameAndEmailToUser < ApplicationRecord
  add_column :users, :name, :string
  add_column :users, :email, :string
end

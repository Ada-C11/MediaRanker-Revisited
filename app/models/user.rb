class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :name, uniqueness: true, presence: true #changed this from username to name; can add username later

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid]
    user.provider = "github"
    user.name = auth_hash[:info][:nickname]
    user.email = auth_hash[:info][:email]

    # Note that the user has not been saved.
    # That is done in the users#create action.
    return user
  end
end

class User < ApplicationRecord
  has_many :votes, dependent: :nullify
  has_many :ranked_works, through: :votes, source: :work
  has_many :works, dependent: :nullify
  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    user = User.new
    user.username = auth_hash["info"]["nickname"]
    user.name = auth_hash["info"]["name"]
    user.email = auth_hash["info"]["email"]
    user.uid = auth_hash[:uid]
    user.provider = "github"

    return user
  end
end

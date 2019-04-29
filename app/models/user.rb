class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash["uid"]
    user.name = auth_hash["name"]
    user.email = auth_hash["email"]
    user.provider = auth_hash["provider"]
    return user
  end
end

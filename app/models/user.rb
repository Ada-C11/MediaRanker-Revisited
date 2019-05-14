class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :name, uniqueness: true, presence: true

  def self.get_authorized_user(auth_hash)
    user = User.find_by(name: auth_hash["info"]["name"], uid: auth_hash[:uid])
    unless user
      user = User.new
      user.uid = auth_hash[:uid]
      user.provider = "github"
      user.name = auth_hash["info"]["name"]
      user.email = auth_hash["info"]["email"]
    end

    return user
  end
end

require "test_helper"

describe User do
  describe "relations" do
    it "has a list of votes" do
      dan = users(:dan)
      dan.must_respond_to :votes
      dan.votes.each do |vote|
        vote.must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:dan)
      dan.must_respond_to :ranked_works
      dan.ranked_works.each do |work|
        work.must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new
      user.valid?.must_equal false
      user.errors.messages.must_include :uid
      user.errors.messages.must_include :provider
    end

    it "requires a unique user id and a provider" do
      uid = 222333
      provider = "github"
      user1 = User.new(uid: uid, provider: provider)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(uid: nil, provider: nil)
      result = user2.save
      result.must_equal false
      user2.errors.messages.must_include :uid
      user2.errors.messages.must_include :provider
    end
  end
end

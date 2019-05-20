require "test_helper"

describe User do
  describe "relations" do
    before do
      @dan = users(:dan)
    end
    it "has a list of votes" do
      @dan.must_respond_to :votes
      @dan.votes.each do |vote|
        vote.must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      @dan.must_respond_to :ranked_works
      @dan.ranked_works.each do |work|
        work.must_be_kind_of Work
      end
    end

    it "has many works" do
      @dan.works.length.must_equal 2
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new
      user.valid?.must_equal false
      user.errors.messages.must_include :username
    end

    it "requires a unique username" do
      username = "test username"
      user1 = User.new(username: username)

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(username: username)
      result = user2.save
      result.must_equal false
      user2.errors.messages.must_include :username
    end
  end
end

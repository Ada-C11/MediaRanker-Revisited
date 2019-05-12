require "test_helper"

describe UsersController do
  let(:user) { users(:user1) }

  describe "index" do
    it "should get index when users exist" do
      get users_path

      must_respond_with :success
    end
    it "should get index when no users exist" do
      User.all do |user|
        user.destroy
      end

      get users_path

      must_respond_with :success
    end
  end
  # describe "create" do
  #   it "can log in an existing user" do

  #     expect {
  #       user = perform_login(user)
  #     }.wont_change "User.count"

  #     expect(session[:user_id]).must_equal user.id
  #   end
  # end
end

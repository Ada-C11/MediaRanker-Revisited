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

  describe "login" do
    it "can log in an existing user" do
      user = perform_login

      expect {
        user = perform_login(user)
      }.wont_change "User.count"

      expect(session[:user_id]).must_equal user.id

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Logged in as returning user #{user.name}"
      
      # must_redirect_to root_path
    end

  end
end

require "test_helper"
require "pry"

# Wave 2: Controller Tests on upvote and UsersController

# Add tests around logging in functionality using OAuth mocks
# Add tests around logging out functionality using OAuth mocks
# Add tests to the WorksController upvote action using OAuth mocks
# Be sure to test nominal and edge cases

describe UsersController do
  describe "log in/log out" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      expect(flash[:success]).must_equal "Logged in as returning user #{user.username}"
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "satan", email: "test@user.com")

      perform_login(user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      expect(flash[:success]).must_equal "Logged in as new user #{user.username}"
      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
    end
  end

  describe "logout" do
    it "can logout user" do
      perform_login

      delete logout_path

      expect(session[:user_id]).must_be_nil
      expect(flash[:success]).must_equal "Successfully logged out!"
      must_redirect_to root_path
    end
  end

  describe "index on log in " do
    it "should get index when user is logged it" do
      perform_login

      get users_path

      must_respond_with :success
    end

    it "should not get index when logged out" do
      #   delete logout_path
      get users_path

      must_respond_with :redirect
      must_redirect_to root_path

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "you have to be logged in to see this!"
    end
  end
end

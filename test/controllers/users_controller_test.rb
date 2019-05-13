require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:dan)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = users(:kari)

      perform_login(user)

      must_redirect_to root_path

      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
    end
  end
  describe "logout" do
    it "logs out user" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)

      delete logout_path

      must_redirect_to root_path

      User.count.must_equal start_count

      session[:user_id].must_equal nil
    end
  end
end

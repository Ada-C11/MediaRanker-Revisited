require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Should have created a new user
      User.count.must_equal start_count + 1

      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "redirects to the login route if given invalid user data" do
    end

    it "logs out a user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)

      delete logout_path

      must_redirect_to root_path

      # Should have created a new user
      User.count.must_equal start_count

      # The new user's ID should be set in the session
      session[:user_id].must_equal nil
    end
  end
end

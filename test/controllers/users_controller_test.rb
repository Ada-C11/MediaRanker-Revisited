require "test_helper"

describe UsersController do
  describe "create" do
    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, name: "test_user", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:grace)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, name: "", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path
      expect(flash[:error]).must_equal "Could not create new user account: {:name=>[\"can't be blank\"]}"
      User.count.must_equal start_count
      session[:user_id].must_equal nil
    end
  end

  describe "destroy" do
    it "responds with a redirect and sets session user id to nil" do
      user = users(:grace)
      perform_login(user)
      post logout_path(user)
      expect(flash[:success]).must_equal "Successfully logged out!"
      must_respond_with :redirect
    end
  end
end

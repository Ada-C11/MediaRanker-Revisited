require "test_helper"

describe UsersController do
  describe "index" do
    it "should get index" do
      get users_path
      must_respond_with :success
    end
  end

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:dan)

      perform_login(user)

      get auth_callback_path(:github)
      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      new_user = User.create(provider: "github", uid: 99999, username: "new_user", email: "new_user@user.com")

      perform_login(new_user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count
      invalid_user = User.new(provider: "github", uid: 99999, name: "", email: "invalid_user@user.com")

      perform_login(invalid_user)

      must_redirect_to root_path

      User.count.must_equal start_count
      session[:user_id].must_equal nil
    end
  end

  describe "destroy" do
    it "responds with a redirect and sets session user id to nil" do
      user = users(:dan)

      perform_login(user)
      delete logout_path(user)

      expect(flash[:success]).must_equal "Successfully logged out"
      must_redirect_to root_path
      session[:user_id].must_equal nil
    end
  end
end

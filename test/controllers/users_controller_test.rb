require "test_helper"

describe UsersController do
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
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      perform_login(user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "redirects to the root path if given invalid user data" do
      start_count = User.count
      user = User.new(provider: "github", uid: nil, username: nil, email: nil)

      perform_login(user)

      must_redirect_to root_path

      User.count.must_equal start_count

      session[:user_id].must_be_nil
    end
  end
end

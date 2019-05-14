require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:grace)

      perform_login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      perform_login(user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end
  end

  describe "logout" do
    it "resets session_id to nil" do
      user = users(:grace)

      perform_login(user)

      delete logout_path
      must_respond_with :redirect

      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end
end

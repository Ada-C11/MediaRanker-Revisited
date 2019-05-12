require "test_helper"

describe UsersController do
  describe "auth_callback in the create action" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:user1)

      perform_login(user)

      expect(session[:user_id]).must_equal user.id
      expect(User.count).must_equal start_count
      expect(flash[:result_text]).must_include "Successfully logged in as existing user"
      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(uid: 999, provider: "github", username: "testuser")
      perform_login(user)
      new_user = User.find_by(id: session[:user_id])

      expect(User.count).must_equal start_count + 1
      expect(session[:user_id]).must_equal new_user.id
      expect(flash[:result_text]).must_equal "Logged in as new user"
      must_redirect_to root_path
    end

    it "redirects to the root route for invalid user data" do
      start_count = User.count
      user = User.new(uid: 999, provider: "github")
      perform_login(user)

      expect(User.count).must_equal start_count
      expect(flash[:message]).must_include "Could not create new user account"
      must_redirect_to root_path
    end
  end

  describe "logging out of OAuth in the destroy action" do
    it "can successfully log out a user by setting session id to nil" do
      user = users(:user1)
      perform_login(user)

      expect(session[:user_id]).must_equal user.id

      delete logout_path

      expect(session[:user_id]).must_equal nil
    end
  end
end

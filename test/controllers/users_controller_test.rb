require "test_helper"

# Add tests around logging in functionality using OAuth mocks
# Add tests around logging out functionality using OAuth mocks
# Add tests to the WorksController upvote action using OAuth mocks
# Be sure to test nominal and edge cases

describe UsersController do
  describe "login" do
    it "can login" do
      # OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      #     :provider => 'github',
      #     :uid => '123545'
      #     # etc.
      #   })

      user = User.first

      expect {
        perform_login(user)
      }.wont_change "User.count"

      expect(session[:user_id]).must_equal user.id
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      new_user = User.new(provider: "github", uid: 99999, username: "random_user", email: "test@user.com")

      perform_login(new_user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count
      new_user = User.new(provider: "github", uid: 99999, username: "", email: "test@user.com")

      perform_login(new_user)

      must_redirect_to root_path

      User.count.must_equal start_count
    end
  end

  describe "logout" do
    it "resets session_id to nil" do
      perform_login
      delete logout_path
      must_respond_with :redirect
      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end
end

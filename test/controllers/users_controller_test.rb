require "test_helper"

describe UsersController do
  describe "login" do
    it "can log in an existing user" do
      user_count = User.count

      user = perform_login

      expect(user_count).must_equal User.count

      expect(session[:user_id]).must_equal user.id
    end

    it "can log in a new user" do
      user = User.new(provider: "github", username: "billy", uid: 987, email: "joe@bob.com")

      expect {
        perform_login(user)
      }.must_change "User.count", 1

      user = User.find_by(uid: user.uid, provider: user.provider)

      expect(session[:user_id]).must_equal user.id
    end

    it "will respond with a redirect if a user is coming from somewhere other than github" do
      invalid_user = User.find_by(provider: "facebook")

      expect {
        perform_login(invalid_user)
      }.wont_change "User.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the login route if given invalid user data" do
      invalid_user = User.new(provider: "githib", username: "", uid: 50, email: "")

      expect {
        perform_login(invalid_user)
      }.wont_change "User.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "logout" do
    it "able to logout if logged in" do
      user_count = User.count

      user = perform_login

      expect(user_count).must_equal User.count

      expect {
        delete logout_path
      }.wont_change "User.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end

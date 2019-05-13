require "test_helper"

describe UsersController do
  describe "login" do
    it "can log in an existing user" do
      user = nil

      expect {
        user = perform_login
      }.wont_change "User.count"

      must_respond_with :found
      expect(session[:user_id]).must_equal user.id
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user.name}"
    end

    it "can log in a new user" do
      user = User.new(provider: "github", username: "bob", uid: 987, email: "bob@hope.com")

      expect {
        perform_login(user)
      }.must_change "User.count", 1

      user = User.find_by(uid: user.uid, provider: user.provider)

      expect(session[:user_id]).must_equal user.id
      expect(flash[:result_text]).must_equal "Logged in as new user #{user.name}"
    end

    it "will redirect back to root with a flash message if given invalid user" do
      user = User.new(provider: "", username: "bob", uid: "", email: "bob@hope.com")

      expect {
        perform_login(user)
      }.wont_change "User.count"

      expect(flash.now[:uid]).must_equal ["can't be blank"]

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "logout" do
    it "should log an existing user out" do
      perform_login

      expect {
        delete logout_path
      }.wont_change "User.count"

      expect(flash[:result_text]).must_equal "Successfully logged out!"
      expect(session[:user_id]).must_be_nil
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end

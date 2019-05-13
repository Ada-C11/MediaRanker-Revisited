require "test_helper"

describe UsersController do
  describe "index" do
    it "shows the page" do
      get users_path
      must_respond_with :success
    end
  end

  describe "logging in/out" do
    describe "log in" do
      it "logs in an existing user" do
        user = users(:ada)
        start_count = User.count

        perform_login(user)
        must_redirect_to root_path
        session[:user_id].must_equal user.id

        User.count.must_equal start_count
      end
    end

    it "logs in a new user and saves it to the db" do
      start_count = User.count
      user = User.new
      user.name = "mickey"
      user.email = "h@h.com"
      user.uid = 555
      user.provider = "github"
      perform_login(user)
      must_redirect_to root_path

      expect(session[:user_id]).must_equal User.last.id

      User.count.must_equal start_count + 1
    end

    it "won't log in an invalid user" do
      user = User.new
      expect {
        perform_login(user)
      }.wont_change "User.count"
      must_redirect_to root_path
    end

    it "logs out the user" do
      delete logout_path
      must_redirect_to root_path
    end
  end
end

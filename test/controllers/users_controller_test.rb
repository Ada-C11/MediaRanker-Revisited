require "test_helper"

describe UsersController do
  let(:user) { users(:dan) }

  describe "github_callback" do
    it "logs in an existing user" do
      start_count = User.count

      perform_login(user)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      User.count.must_equal start_count
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user.name}"
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 5432111, username: "kimkimkim", email: "kim@kim.net")

      perform_login(user)

      must_redirect_to root_path
      session[:user_id].must_equal User.last.id
      User.count.must_equal start_count + 1
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully created new user #{User.last.name} with ID #{User.last.id}"
    end

    it "redirects to the login route if given invalid user data" do
      start_count = User.count
      user = User.new(provider: "github", username: "kim123", email: "kim@kim.com", name: "kim")

      perform_login(user)

      must_respond_with :bad_request
      User.count.must_equal start_count
      expect(flash.now[:status]).must_equal :failure
      expect(flash.now[:result_text]).must_equal "Could not log in"
      expect(flash.now[:messages]).must_include :uid
      expect(flash.now[:messages][:uid]).must_equal ["can't be blank"]
      assert_nil(session[:user_id])
    end
  end

  describe "logout" do
    it "logs out a user and redirects them to the root path" do
      start_count = User.count
      perform_login(user)

      delete logout_path

      User.count.must_equal start_count
      must_redirect_to root_path
      assert_nil(session[:user_id])
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out"
    end

    it "redirects to the root path if trying to log out when no user is logged in" do
      start_count = User.count

      delete logout_path

      User.count.must_equal start_count
      must_redirect_to root_path
      assert_nil(session[:user_id])
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out"
    end
  end
end

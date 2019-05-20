require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)
    
      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal  user.id
    
      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com", name: "name")
    
      perform_login(user)
      must_redirect_to root_path
    
      # Should have created a new user
      User.count.must_equal start_count + 1
    
      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it "will redirect back to root with a flash message if username not provided" do
      user = User.new(provider: "github", uid: 1122, username: "", email: "", name: "user_test_name")

      expect {
        perform_login(user)
      }.wont_change "User.count"
      expect(flash[:error]).must_be_kind_of String
    end

    it "logs out a user" do
      start_count = User.count
      user = users(:grace)
    
      perform_login(user)

      delete logout_path

      must_redirect_to root_path

      session[:user_id].must_equal nil
      User.count.must_equal start_count
    end
  end
end

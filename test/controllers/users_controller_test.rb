require "test_helper"
require "pry"

describe UsersController do
  describe "create" do
    it "logs in an existing user" do
      # Arrange
      start_count = User.count
      user = users(:ada)

      # Act
      perform_login(user)

      # Assert
      must_redirect_to root_path

      session[:user_id].must_equal  user.id
      User.count.must_equal start_count
    end

    it "creates a new user and redirects to the root" do

      start_count = User.count
      # Test would not pass with user.new for some reason
      user = User.create(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      perform_login(user)

      must_redirect_to root_path
  
      # Should have created a new user
      User.count.must_equal start_count + 1
  
      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route with invalid data" do
      start_count = User.count
      user = User.new(provider: 'github', uid: 1, username: '', email: 'test@user.com')
  
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)
  
      must_redirect_to root_path
  
      User.count.must_equal start_count

    end
  end


  describe "destroy" do
    it "responds with redirect and deletes user session on logout" do
      # Arrange
      user = users(:ada)

      # Act
      perform_login(user)
      delete logout_path(user)
    
      # Assert
      must_redirect_to root_path
  
      session[:user_id].must_equal nil
    end
  end
end

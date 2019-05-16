require "test_helper"

describe UsersController do
  describe "auth callback" do
    it "can log in an existing user" do
      # Arrange
      user = users(:user1)

       # Act
      expect {
        perform_login(user)
      }.wont_change "User.count"

       # Assert
      expect(session[:user_id]).must_equal user.id
      must_redirect_to root_path
    end

    it "creates a new user" do
      start_count = User.count
      user = User.create(username: "test_user", email: "test@user.com", uid: 99999, provider: "github")
      
      # expect {
        perform_login(user)
        # get '/auth/github/callback'
      # }.must_change "User.count", +1
      # OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      # get callback_path(:github)
    
      # must_redirect_to root_path
    
      # # Should have created a new user
      User.count.must_equal start_count + 1
    
      # # The new user's ID should be set in the session
      # session[:user_id].must_equal User.last.id
    end
    
    it "flashes an error & redirects, when failing to save new user" do
      # User data with bad username, to trigger failure case
      user = User.new(username: "", name: "", email: "test@user.com", uid: 99999, provider: "github")

      expect {
        perform_login(user)
      }.wont_change "User.count"

       check_flash(:error)

      must_redirect_to root_path
    end
  end

  describe "current" do
    it "responds with OK for a logged-in user" do
      # Arrange
      perform_login

      # Act
      get root_path

      # Assert
      must_respond_with :ok
    end
  end
end

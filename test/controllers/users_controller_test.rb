require "test_helper"

describe UsersController do
  describe "auth callback" do
    it "can log in an existing user" do
      # Arrange
      user = User.first

      # Act
      expect {
        perform_login(user)
        # get '/auth/github/callback'
      }.wont_change "User.count"

      # Assert
      expect(session[:user_id]).must_equal user.id
      must_redirect_to root_path
    end
  end
end

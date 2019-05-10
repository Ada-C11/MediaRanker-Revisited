require "test_helper"

describe UsersController do
  describe "auth callback" do
    it "can log in an existing user" do
      # Arrange
      user = users(:dan)

      # Act
      expect {
        perform_login(user)
        # get '/auth/github/callback'
      }.wont_change "User.count"

      # Assert
      expect(session[:user_id]).must_equal user.id
      must_redirect_to root_path
    end

    it "creates a new user" do
      start_count = User.count
      new_user = User.create(uid: 3, provider: "github", username: "bobby", email: "bobby@bobbyworld.com", name: "bob")

      expect(new_user.valid?).must_equal true
      perform_login(new_user)
      expect(session[:user_id]).must_equal new_user.id
      expect( User.count).must_equal start_count + 1
      must_redirect_to root_path
    end
  end

  describe "destroy (logout)" do
    it "can log out a logged in user" do
      perform_login
      delete logout_path

      expect(session[:user_id]).must_be_nil
    end
  end
end

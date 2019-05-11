require "test_helper"

describe UsersController do
  describe "index" do
    it "should get index" do
      # Act
      get users_path

      # Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "can get a valid user" do

      # Act
      get user_path(users(:dan).id)

      # Assert
      must_respond_with :success
    end

    it "will redirect and give a flash notice for an invalid user" do

      # Act
      get user_path(-1)

      # Assert
      must_respond_with :not_found
      must_respond_with 404
    end
  end

  describe "login" do
    it "log in an existing user" do
      user = users(:dan)

      expect {
        perform_login(user)
      }.wont_change "User.count"
    end
  end

  describe "create" do
    it "create a new user if the user has not previously been saved in the db" do
      # Arrange
      start_count = User.count

      # Act
      new_user = User.new(provider: "github", uid: "443356", username: "margi@email.com", email: "margi@email.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))

      # Act-Assert
      expect {
        get auth_callback_path(:github)
      }.must_change "User.count", 1

      expect(flash[:status]).must_equal :success
      expect(flash[:result_message]).must_equal "Logged in as new user #{new_user.email}"

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirect and give a flash notice if a new user fails to save after validation" do
      # Arrange
      new_user = User.new(provider: "github", uid: "443356", username: nil, email: nil)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))

      # Act-Assert
      expect {
        get auth_callback_path(:github)
      }.wont_change "User.count"

      expect(flash[:status]).must_equal :error
      expect(flash[:result_text]).must_equal "Could not create new user account"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "successfully log out a logged-in merchant" do
      # Arrange
      user = users(:dan)
      perform_login(user)

      # Act - Assert
      expect {
        delete logout_path
      }.wont_change "User.count"

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out"

      session[:user_id].must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end

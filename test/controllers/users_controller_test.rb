require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      new_user = User.new(
        username: "new user",
        uid: 1234567,
        email: "new_user@gmail.com",
        provider: :github,
      )
      perform_login(new_user)

      must_redirect_to root_path
      User.count.must_equal start_count + 1
    end

    it "redirects to the login route if given invalid user data(user can't be saved)" do
     
        start_count = User.count
        invalid_user = User.new(provider: "github", username: " ", email: " ")

        perform_login(invalid_user)


        must_redirect_to auth_callback_path(:github)

        session[:user_id].must_be_nil

        User.count.must_equal start_count
    
    end
  end

  it "creates a new user" do
    start_count = User.count
    user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
    get auth_callback_path(:github)

    must_redirect_to root_path

    # Should have created a new user
    User.count.must_equal start_count + 1

    # The new user's ID should be set in the session
    session[:user_id].must_equal User.last.id
  end
end

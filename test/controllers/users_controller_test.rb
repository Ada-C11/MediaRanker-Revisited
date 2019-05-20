require "test_helper"

describe UsersController do
  describe UsersController do
    describe "auth_callback" do
      it "logs in an existing user and redirects to the root route" do
        start_count = User.count

        user = users(:grace)

        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

        get auth_callback_path(:github)
        must_redirect_to root_path

        session[:user_id].must_equal user.id

        User.count.must_equal start_count
      end

      it "creates an account for a new user and redirects to the root route" do
        start_count = User.count
        new_user = User.new(
          username: "new user",
          uid: 123456789,
          email: "new_user@gmail.com",
          provider: :github,
        )

        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))
        get auth_callback_path(:github)

        must_redirect_to root_path

        User.count.must_equal start_count + 1
        session[:user_id].must_equal User.last.id
      end

      it "redirects to the login route if given invalid user data" do
        start_count = User.count
        invalid_user = User.new(provider: "github", username: " ", email: " ")

        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(invalid_user))
        get auth_callback_path(:github)

        must_redirect_to auth_callback_path(:github)

        session[:user_id].must_be_nil

        User.count.must_equal start_count
      end
    end

    describe "logout" do
      it "logs out user if they are logged in" do
        user = users(:grace)
        perform_login(user)
        expect(session[:user_id]).must_equal user.id

        delete logout_path

        must_redirect_to root_path

        expect(session[:user_id]).must_be_nil
      end

      it "redirects to root path if there is no user logged in" do
        delete logout_path

        must_redirect_to root_path

        expect(session[:user_id]).must_be_nil
      end
    end
  end
end

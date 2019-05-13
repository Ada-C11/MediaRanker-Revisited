require "test_helper"

describe UsersController do
  let (:user_one) { users(:dan) }
  let (:user_two) { users(:kari) }
  describe "index" do
    describe "logged in user " do
      it "should get index when users exist" do
        perform_login(user_one)
        get users_path

        must_respond_with :success
      end

      it "should get index when no users exist" do
        perform_login(user_one)
        User.all do |user|
          user.destroy
        end

        get users_path
        must_respond_with :success
      end
    end

    describe "guest user" do
      it "will flash error message and redirect if user is not logged in" do
        get users_path
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "You must be logged in to see this page!"
        must_redirect_to root_path
      end
    end
  end

  describe "show" do
    describe "logged in user" do
      it "responds with success if user exists" do
        perform_login(user_one)

        get user_path(user_one.id)
        must_respond_with :success
      end

      it "responds with a 404 if user does not exist" do
        perform_login(user_one)

        get user_path(-1)
        must_respond_with :not_found
      end
    end

    describe "guest user" do
      it "will flash error message and redirect if user is not logged in" do
        get user_path(user_one.id)
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "You must be logged in to see this page!"
        must_redirect_to root_path
      end
    end
  end

  describe "create" do
    it "can log in an existing user" do
      user = perform_login(user_one)

      expect { perform_login(user_one) }.wont_change "User.count"
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Logged in as returning user #{user_one.name}"
      expect(session[:user_id]).wont_be_nil
      must_redirect_to root_path
    end

    it "can log in a new user" do
      new_user = User.new(uid: 999, provider: "github", username: "angela", email: "test@test.com")
      expect { perform_login(new_user) }.must_change "User.count", 1
      user = User.find_by(uid: new_user.uid, provider: new_user.provider)

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Logged in as new user #{user.name}"
      expect(session[:user_id]).must_equal user.id
      must_redirect_to root_path
    end

    it "flashes an error and redirects to root if user info is invalid" do
      bad_user = User.new(username: nil, uid: 999, provider: "github")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(bad_user))

      expect { get auth_callback_path(:github) }.wont_change "User.count"
      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Could not create new user account: "
    end

    it "flashes an error and redirects to root if provider does not grant permission" do
      OmniAuth.config.mock_auth[:github] = nil

      get auth_callback_path(:github)
      expect {
        get auth_callback_path(:github)
      }.wont_change "User.count"
      must_respond_with :redirect
      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Could not create new user account: "
    end
  end

  describe "destroy" do
    it "can log out a user" do
      perform_login(user_one)
      expect(flash[:result_text]).must_equal "Logged in as returning user #{user_one.name}"
      expect(session[:user_id]).wont_be_nil

      delete logout_path
      expect(session[:user_id]).must_be_nil
      expect(flash[:result_text]).must_equal "Successfully logged out!"
      must_redirect_to root_path
    end
  end
end

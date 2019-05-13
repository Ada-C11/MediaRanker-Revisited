require "test_helper"

describe UsersController do
  let (:user_one) { users(:dan) }
  let (:user_two) { users(:kari) }
  describe "index" do
    it "should get index when users exist" do
      get users_path
      must_respond_with :success
    end

    it "should get index when no users exist" do
      User.all do |user|
        user.destroy
      end

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "responds with success if user exists" do
      get user_path(user_one.id)
      must_respond_with :success
    end

    it "responds with a 404 if user does not exist" do
      get user_path(-1)
      must_respond_with :not_found
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
      new_user = User.new(uid: 999, provider: "github", email: "test@test.com", name: "angela")
      expect { perform_login(new_user) }.must_change "User.count", 1
      user = User.find_by(uid: new_user.uid)

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Logged in as new user #{user.name}"
      expect(session[:user_id]).must_equal user.id
      must_redirect_to root_path
    end

    it "flashes an error and redirects to root if user cannot be created" do
      bad_user = User.new(username: "test", uid: nil, provider: "github")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(bad_user))

      expect { get auth_callback_path(:github) }.wont_change "User.count"
      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Could not create new user account: "
    end
  end
end

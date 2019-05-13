require "test_helper"
require "pry"
describe UsersController do
  let (:user) { users(:dan) }

  describe "index" do
    it "can get the index path" do
      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "returns a 404 status code if the user doesn't exist" do
      user_id = 12345392487
      expect(User.find_by(id: user_id)).must_be_nil

      get user_path(user_id)

      must_respond_with :not_found
    end

    it "functions for a user that exists" do
      get user_path(user.id)

      must_respond_with :success
    end
  end

  describe "create" do
    it "will login a returning user and redirect to the root route" do
      start_count = User.count

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "will create an account for a new user and redirect to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, email: "test@user.com", username: "test_user")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "will redirect to the root route if given invalid user data" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, email: "test@user.com", username: nil)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count
    end
  end

  describe "destroy" do
    it "will logout user and redirect to root route" do
      start_count = User.count
      perform_login(user)
      delete logout_path

      expect(session[:user_id]).must_equal nil
      must_redirect_to root_path
      User.count.must_equal start_count
    end
  end
end

require "test_helper"

describe UsersController do
  let(:user) { users(:dan) }

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
    it "should get respond with success if user exists" do
      user = perform_login
      get user_path(user.id)
      must_respond_with :success
    end

    it "should get respond with 404 not found if ID is invalid" do
      user = perform_login
      get user_path(-7)

      must_respond_with :not_found
    end
  end

  describe "login" do
    it "can log in an existing user" do
      expect {
        perform_login(user)
      }.wont_change "User.count"

      expect(session[:user_id]).must_equal user.id

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Logged in as returning user #{user.name}"

      must_redirect_to root_path
    end

    it "can log in a new user" do
      new_user = User.new(provider: "github", username: "lola_cat", uid: 987, email: "lola@justcatthings.com")

      expect {
        perform_login(new_user)
      }.must_change "User.count", 1

      user = User.find_by(uid: new_user.uid, provider: new_user.provider)

      expect(session[:user_id]).must_equal user.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Logged in as new user #{user.name}"

      must_redirect_to root_path
    end

    it "flashes an error if new user could not be created" do
      OmniAuth.config.mock_auth[:github] = nil

      get auth_callback_path(:github)

      expect {
        get auth_callback_path(:github)
      }.wont_change "User.count"

      expect(flash[:result_text]).must_equal "Could not create new user account: {:username=>[\"can't be blank\"]}"

      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "can logout a user" do
      perform_login(user)
      logout_data = {
        user: {
          username: user.username,
        },
      }
      delete logout_path, params: logout_data

      expect(session[:user_id]).must_be_nil

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out!"
      must_redirect_to root_path
    end
  end
end

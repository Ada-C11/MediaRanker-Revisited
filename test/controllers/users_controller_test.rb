require "test_helper"

describe UsersController do
  describe "index" do
    it "lists all users" do
      perform_login
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "should display show page for user" do
      user = perform_login(users(:ada))
      # user = users(:ada).id
      get users_path(user)
      must_respond_with :success
    end

    it "should redirect when given a not valid user" do
      user = users(:ada).id
      users(:ada).destroy
      get user_path(user)
      must_respond_with :redirect
      expect(flash[:error]).must_equal "You must be logged in to do this action"
    end
  end

  describe "Create" do
    it "logs in an existing user and redirects to the root route" do
      perform_login
      # Count the users, to make sure we're not (for example) creating
      # a new user every time we get a login request
      start_count = User.count

      # Get a user from the fixtures
      user = users(:grace)

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Send a login request for that user
      # Note that we're using the named path for the callback, as defined
      # in the `as:` clause in `config/routes.rb`
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      expect(flash[:success]).must_equal "Logged in as returning user, #{user.username}"
      expect(User.count).must_equal start_count
    end

    it "log in a as a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 343434, username: "user", email: "user@test.com", name: "user_name")

      perform_login(user)

      must_redirect_to root_path
      user = User.find_by(id: session[:user_id])
      expect(User.count).must_equal start_count + 1
      expect(flash[:success]).must_equal "Logged in as new user #{user.username}"
      expect(session[:user_id]).must_equal user.id
    end

    it "will not login and redirect to root path if not comming from GitHub" do
      user = User.new(provider: "Not github", uid: 343434, username: "user", email: "user@test.com", name: "user_name")
      expect { perform_login(user) }.wont_change "User.count"
    end
  end

  describe "current" do
    it "responds with success when a user is logged in" do
      perform_login
      get current_user_path
      must_respond_with :found
    end

    it "will display a flash message if no user is logged in" do
      get current_user_path

      must_respond_with :redirect
      expect(flash[:error]).must_equal "You must be logged in to do this action"
    end
  end

  describe "destroy" do
    it "will close the session an redirect to root path" do
      perform_login
      user = users(:ada)
      perform_login(user)
      delete logout_path
      must_respond_with :redirect
      expect(flash[:success]).must_equal "Successfully logged out. Bye, #{user.username}!"
    end

    it "will display a flash message if there is not a logged in user" do
      delete logout_path
      expect(flash[:error]).must_equal "There is not a logged in user."
    end
  end
end

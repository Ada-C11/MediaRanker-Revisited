require "test_helper"

describe UsersController do
    describe "auth_callback" do
      it "logs in an existing user and redirects to the root route" do
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
  
      it "creates an account for a new user and redirects to the root route" do
      end
  
      it "redirects to the login route if given invalid user data" do
      end
    end

  describe "destroy" do
  
    it "removes the user from the database" do
      skip
      user_params = {
      provider: "github",
      uid: 6666666,
      email: "ada@adadevelopersacademy.org",
      username: "randomname",
      name: "niv"

      }

      doomed_user = User.create!(user_params)

      expect {
        delete user_path(doomed_user.id)
      }.must_change "User.count", -1
    end

  end

  describe "index" do
    it "can get index" do
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "shows a user that exists" do
      get user_path(users(:ada).id)
      must_respond_with :ok
    end

    it "returns a 404 status code if the work doesn't exist" do
      get user_path(-1)
      must_respond_with :not_found
    end

  end

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
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

    it "creates an account for a new user and redirects to the root route" do
      skip
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


      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal (start_count + 1)
      must_redirect_to root_path
    end

    it "redirects to the login route if given invalid user data" do
    end
  end

end

require 'test_helper'

describe UsersController do
  describe 'auth_callback' do
    it 'logs in an existing user and redirects to the root route' do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal  user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it 'creates an account for a new user and redirects to the root route' do
      start_count = User.count
      user = User.create(provider: 'github', uid: 99_999, username: 'test_user', email: 'test@user.com')

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Should have created a new user
      User.count.must_equal start_count + 1

      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it 'redirects to the login route if given invalid user data' do
      start_count = User.count
      user = User.new(provider: 'github', uid: -1, username: 'test', email: 'test@user.com')

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it 'redirects to the login route and deletes the session when user logs out' do
      user = users(:grace)
      perform_login(user)
      delete logout_path(user)
      must_redirect_to root_path

      session[:user_id].must_equal nil
    end
  end

  describe "guest user" do
    it "cannot access users index page " do
      get users_path

      must_respond_with :redirect
      must_redirect_to root_path
      flash[:status].must_equal :failure
      flash[:result_text].must_equal 'You must be logged in to perform this action'
    end
  end
end

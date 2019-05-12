require "test_helper"

# Wave 2: Controller Tests on upvote and UsersController

# Add tests around logging in functionality using OAuth mocks
# Add tests around logging out functionality using OAuth mocks
# Add tests to the WorksController upvote action using OAuth mocks
# Be sure to test nominal and edge cases

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:dan)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end
  end
end

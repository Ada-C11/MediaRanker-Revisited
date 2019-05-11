require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user" do
      start_count = User.count
      user = users(:dan)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end
  end
end

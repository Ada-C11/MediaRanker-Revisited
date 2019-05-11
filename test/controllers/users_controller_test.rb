require "test_helper"

describe UsersController do
  describe "auth_callback" do
    before do
      @start_count = User.count
    end
    it "logs in an existing user" do
      user = users(:dan)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal @start_count
    end

    it "creates a new user" do
      user = User.new(
        provider: "github",
        uid: 9999999,
        username: "fishy",
      )

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal @start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "redirects to different route if given invalid user data" do
    end
  end
end

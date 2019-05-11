require "test_helper"

describe UsersController do
  describe "auth_callback" do
    before do
      @start_count = User.count
    end
    it "logs in an existing user" do
      user = users(:dan)

      perform_login(user)
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

      perform_login(user)
      must_redirect_to root_path

      User.count.must_equal @start_count + 1
      session[:user_id].must_equal User.last.id
    end

    it "redirects to different route if given invalid user data" do
      user = User.new(
        provider: "bogus",
        uid: "bogus",
        username: "",
      )

      perform_login(user)
      flash[:error].wont_be_nil
      must_redirect_to root_path
    end
  end
end

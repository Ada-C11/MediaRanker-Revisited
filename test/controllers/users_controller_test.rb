require "test_helper"
require "pry"

describe UsersController do
  describe "create" do
    it "logs in and creates a new user with good data" do
      user = User.new(provider: "github", uid: 122, username: "brand_new", email: "test@test.com")

      perform_login(user)

      expect(User.count).must_equal 3
      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:user_id]).must_equal User.last.id
      check_flash
    end

    it "doesn't create a new user with bad data" do
      user = User.new(provider: "github")

      perform_login(user)

      expect(User.count).must_equal 2
      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
      check_flash(:error)
    end

    it "logs in a returning user" do
      user = users(:dan)

      perform_login(user)

      expect(User.count).must_equal 2
      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      check_flash
    end
  end

  describe "destroy" do
    it "logs out the logged in user" do
      user = users(:dan)

      perform_login(user)

      expect(session[:user_id]).must_equal user.id

      delete logout_path

      expect(session[:user_id]).must_equal nil
      check_flash
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects if there's no logged in user" do
      delete logout_path

      check_flash(:error)
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end

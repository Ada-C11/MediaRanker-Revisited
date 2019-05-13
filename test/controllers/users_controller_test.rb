require "test_helper"

describe UsersController do
  describe "index" do
    it "shows the page" do
      get users_path
      must_respond_with :success
    end
  end

  describe "logging in/out" do
    before do
      @user = User.first
    end
  end
end

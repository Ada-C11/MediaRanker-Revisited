require "test_helper"

describe UsersController do
  let (:user_one) { users(:dan) }
  let (:user_two) { users(:kari) }
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
end

require "test_helper"

describe UsersController do
  describe "index" do
    it "should get index" do
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "returns success when given a valid id" do
      user = User.create(username: "Faiza")
      uid = user.id

      get user_path(uid)
      must_respond_with :success
    end

    it "returns not_found when given an invalid id" do
      uid = -1
      get user_path(uid)
      must_respond_with :not_found
    end
  end

  describe "login" do
    it "can login in an existing user" do 
      user_count = User.count

      user = perform_login

      expect(user_count).must_equal User.count
      expect(session[:user_id]).must_equal user.id
      expect(flash[:status]).must_equal :success
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can log in a new user" do
      new_user = User.new(provider: "github", name: "faiza", uid: 999, email: "faiza@email.com")

      expect {

        perform_login(new_user)

      }.must_change "User.count", 1

      user = User.find_by(uid: new_user.uid, provider: new_user.provider)

      expect(session[:user_id]).must_equal user.id
      expect(new_user.name).must_equal user.username
      expect(flash[:status]).must_equal :success
    end
  end

  describe "current" do
    it "responds with redirect if no user is logged in" do 
      get current_user_path
      must_respond_with :redirect
    end
  end

  describe "destroy" do
    it "will let a user logout" do
      current_user = users(:kari)
      delete logout_path
      
      must_respond_with :redirect
    end
  end

  
end

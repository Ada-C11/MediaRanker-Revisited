require "test_helper"

describe UsersController do
  describe "index" do 

    it "loads the users successfully" do 
      get users_path

      must_respond_with :ok
    end

    it "will load the page even with 0 users" do 
      User.destroy_all

      get users_path

      must_respond_with :ok
    end
  end

  describe "show" do 
    it "loads the user show page for existant user" do 
      dan_user = users(:dan)

      get user_path(dan_user)

      must_respond_with :ok
    end

    it "redirects for nonextant user" do 
      invalid_id = User.last.id + 1

      get user_path(invalid_id)

      must_respond_with :not_found
    end
  end

  describe "create (auth_callback)" do
    it "logs in an existing user and redirects to the root route" do
      # Count the users, to make sure we're not (for example) creating
      # a new user every time we get a login request
      start_count = User.count
      user = users(:kari)

      perform_login(user)

      must_redirect_to root_path
      session[:user_id].must_equal user.id
      expect(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(name: "Ted", username: "ted_rocks", email: "ted@gmail.com", uid: 1234563, provider: "github")
      
      perform_login(user)

      must_redirect_to root_path
      expect(session[:user_id]).must_equal User.last.id
      expect(User.count).must_equal start_count + 1
    end

    it "redirects to the login route if given invalid user data" do
      start_count  = User.count
      user = User.new(name: "Carl", email: "carljr@carls.com")

      perform_login(user)

      must_redirect_to root_path
      expect(flash[:result_text]).must_equal "Login unsuccessful: {:username=>[\"can't be blank\"]}"
    end
  end

  describe "destroy" do 
    it "will logout someone who is logged in" do 
      perform_login

      expect {
        delete logout_path
      }.wont_change "User.count"

      assert_nil(session[:user_id])
      must_redirect_to root_path
      expect(flash[:result_text]).must_equal "Successfully logged out!"
    end
  end
end

require "test_helper"
require "test_helper"

describe UsersController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      user = users(:grace)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end
  end

  describe "create" do
    it "creates a new user" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, name: "test_user", email: "test@user.com")

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it "creates an account for a new user and redirects to the root route" do
      skip
    end

    it "logs in an existing user" do
      start_count = User.count
      user = users(:grace)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "redirects to the login route if given invalid user data" do
      skip
    end
  end
  describe "destroy" do
  end
end

# describe "login" do
#     it "successfully adds user information to session hash" do
#       logged_in_user = perform_login
#       get user_path(logged_in_user.id)
#       must_respond_with :success
#     end
#     it "responds with a redirect if username is invalid" do
#       login_data = {
#         name: "",
#       }
#       post login_path, params: login_data
#       must_respond_with :redirect
#     end
#   end

#   describe "logout" do
#     it "reponds with a redirect and sets session user id to nil" do
#       logged_in_user = perform_login
#       post logout_path
#       expect(flash[:notice]).must_equal "Successfully logged out"
#       must_respond_with :redirect
#     end
#   end

# def create
#   auth_hash = request.env["omniauth.auth"]

#   user = User.find_by(uid: auth_hash[:uid], provider: "github")
#   if user
#     flash[:success] = "Logged in as returning user #{user.name}"
#   else
#     user = User.build_from_github(auth_hash)

#     if user.save
#       flash[:success] = "Logged in as new user #{user.name}"
#     else
#       flash[:error] = "Could not create new user account: #{user.errors.messages}"
#       return redirect_to root_path
#     end
#   end

#   session[:user_id] = user.id
#   return redirect_to root_path
# end

# def destroy
#   session[:user_id] = nil
#   flash[:success] = "Successfully logged out!"

#   redirect_to root_path
# end

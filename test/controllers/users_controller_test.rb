require "test_helper"

describe UsersController do
  let(:user) { users(:dan) }
  describe "create (login)" do
    it "logs in an existing user and redirects to the root route" do
      expect { perform_login }.wont_change "User.count"

      expect(session[:user_id]).must_equal user.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user.username}"

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      user = User.new(username: "pennywise1.0",
                      uid: 7655555,
                      email: "penny@wise.com",
                      name: "Penny Wiser",
                      provider: "github")
      expect { perform_login(user) }.must_change "User.count", 1

      user = User.find_by(username: "pennywise1.0")
      expect(session[:user_id]).must_equal user.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully created new user #{user.username} with ID #{user.id}"

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the login route if given invalid user data" do
      user = User.new(username: nil,
                      uid: 999999999,
                      email: "penny@wise.com",
                      name: "Penny Wiser",
                      provider: "github")
      expect { perform_login(user) }.must_change "User.count", 0

      expect(session[:user_id]).must_be_nil
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "Could not log in"
      expect(flash[:messages]).must_equal :username => ["can't be blank"]

      must_respond_with :bad_request
    end
  end
  describe "destroy (logout)" do
    describe "as a logged in user" do
      before do
        perform_login
      end
      it "will set session to nil and redirect to root" do
        expect(session[:user_id]).must_equal user.id
        expect {
          delete logout_path
        }.wont_change "User.count"

        expect(session[:user_id]).must_be_nil
        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully logged out"

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "as a guest (not logged in user)" do
      it "will give flash status failure and redirect to root" do
        expect {
          delete logout_path
        }.wont_change "User.count"

        expect(session[:user_id]).must_be_nil
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "No logged in user to logout"

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end

require "test_helper"
# Add tests around logging in functionality using OAuth mocks
# Add tests around logging out functionality using OAuth mocks
describe UsersController do
  describe "auth callback" do
    it "can log in an existing user" do
      user = User.first
      #Act
      expect {
        perform_login(user)
      }.wont_change "User.count"
      #Assert
      expect(session[:user_id]).must_equal user.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).wont_be_nil
      must_redirect_to root_path
    end

    it "can log in a new user" do
      start_count = User.count
      user = User.new(username: "test-user", name: "test-name", email: "test-name@test.com", uid: 12345, provider: "github")
      perform_login(user)
      expect(User.count).must_equal start_count + 1
      session[:user_id].must_equal User.last.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).wont_be_nil
      must_redirect_to root_path
    end
  end

  it "logins with valid user data" do
    start_count = User.count
    user = User.new(username: "", name: "test-name", email: "test-name@test.com", uid: 12345, provider: "github")
    user.valid?.must_equal false
    perform_login(user)
    expect(User.count).must_equal start_count
    expect(flash[:status]).must_equal :error
    expect(flash[:result_text]).wont_be_nil
    must_redirect_to root_path
  end
end

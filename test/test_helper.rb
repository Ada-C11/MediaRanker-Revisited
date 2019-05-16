ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/skip_dsl"
require "minitest/reporters"  # for Colorized output

#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # Add more helper methods to be used by all tests here...
  def check_flash(expected_status = :success)
    expect(flash[:status]).must_equal(expected_status)
    expect(flash[:message]).wont_be_nil
  end

  def setup
    # Once you have enabled test mode, all requests
    # to OmniAuth will be short circuited to use the mock authentication hash.
    # A request to /auth/provider will redirect immediately to /auth/provider/callback.
    OmniAuth.config.test_mode = true
  end
  
  def mock_auth_hash(user)
    return {
      info: {
        username: user.username,
        email: user.email,
      },
      uid: user.uid,
      provider: user.provider,
    }
  end

  def perform_login(user = nil)
    user ||= User.first

    # Create mock data for this user as though it had come from github

    # Tell OmniAuth to use this data for the next request
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

    get callback_path("github")

    puts user.username
    return user
  end
end


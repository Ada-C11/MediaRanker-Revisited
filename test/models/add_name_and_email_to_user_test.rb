require "test_helper"

describe AddNameAndEmailToUser do
  let(:add_name_and_email_to_user) { AddNameAndEmailToUser.new }

  it "must be valid" do
    value(add_name_and_email_to_user).must_be :valid?
  end
end

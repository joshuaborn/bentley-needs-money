require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
    sign_in people(:user_one)
  end
  test "getting #index" do
    get transfers_path
    assert_response :success
  end
  test "flash message when there are connection requests to accept or deny" do
    ConnectionRequest.create(from: people(:user_two), to: people(:user_one))
    get transfers_path
    assert_response :success
    assert_match "You have one or more connection requests.", flash[:info]
  end
end

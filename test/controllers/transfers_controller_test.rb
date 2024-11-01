require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
  end
  test "getting #index" do
    sign_in people(:user_one)
    get transfers_path
    assert_response :success
  end
end

require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "getting #index" do
    sign_in people(:user_one)
    get transfers_path
    assert_response :success
  end
end

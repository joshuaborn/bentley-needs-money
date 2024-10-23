require "test_helper"

class PaybacksControllerTest < ActionDispatch::IntegrationTest
  test "getting #new" do
    post login_path, params: { person_id: people(:user_one).id }
    get new_payback_path
    assert_response :success
  end
end

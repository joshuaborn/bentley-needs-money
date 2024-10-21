require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  test "getting #index" do
    post login_path, params: { person_id: people(:user_one).id }
    get transfers_path
    assert_response :success
  end
  test "redirection to logins#new if no one is logged in" do
    get transfers_path
    assert_equal "Please log in to access this page.", flash[:warning]
    assert_redirected_to new_login_url
  end
end

require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
  end
  test "should redirect to transfers#index if signed in" do
    sign_in people(:user_one)
    get welcome_index_path
    assert_redirected_to transfers_path
  end
  test "should render welcome page if user not signed in" do
    get welcome_index_path
    assert_response :success
  end
end

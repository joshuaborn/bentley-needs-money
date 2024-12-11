require "test_helper"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
  end
  test "should get index" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    sign_in people(:user_one)
    get connections_url
    assert_response :success
  end
end

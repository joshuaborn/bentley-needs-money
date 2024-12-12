require "test_helper"

class ConnectionRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
    sign_in people(:user_one)
  end
  test "deny a request" do
    connection_request = ConnectionRequest.create(from: people(:user_two), to: people(:user_one))
    assert_difference("ConnectionRequest.count", -1) do
      delete connection_request_path(connection_request)
    end
    assert_redirected_to connections_path
    assert_equal "Connection request from #{connection_request.from.name} denied.", flash[:info]
    assert ConnectionRequest.where(id: connection_request.id).empty?
  end
  test "can't deny a request that is sent to someone else" do
    connection_request = ConnectionRequest.create(from: people(:user_two), to: people(:user_three))
    assert_no_difference("ConnectionRequest.count") do
      delete connection_request_path(connection_request)
    end
    assert_redirected_to connections_path
    assert ConnectionRequest.where(id: connection_request.id).exists?
  end
end

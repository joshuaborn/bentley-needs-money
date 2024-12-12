require "test_helper"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
    sign_in people(:user_one)
  end
  test "should get index" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    get connections_url
    assert_response :success
  end
  test "accept a request" do
    connection_request = ConnectionRequest.create(from: people(:user_two), to: people(:user_one))
    assert_difference("Connection.count", 2) do
      post connections_path, params: { connection_request_id: connection_request.id }
    end
    assert_redirected_to connections_path
    assert_equal "Connection request from #{connection_request.from.name} accepted.", flash[:info]
    assert ConnectionRequest.where(id: connection_request.id).empty?
    assert Connection.where(from: connection_request.from, to: connection_request.to).exists?
    assert Connection.where(to: connection_request.from, from: connection_request.to).exists?
  end
  test "can't accept a request that is sent to someone else" do
    connection_request = ConnectionRequest.create(from: people(:user_two), to: people(:user_three))
    assert_no_difference("Connection.count") do
      post connections_path, params: { connection_request_id: connection_request.id }
    end
    assert_redirected_to connections_path
    assert ConnectionRequest.where(id: connection_request.id).exists?
    assert Connection.where(from: connection_request.from, to: connection_request.to).empty?
    assert Connection.where(to: connection_request.from, from: connection_request.to).empty?
  end
end

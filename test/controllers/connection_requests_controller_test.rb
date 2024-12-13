require "test_helper"
require "minitest/mock"

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
  test "get #new" do
    get new_connection_request_path
    assert_response :success
  end
  test "connection request when a connection already exists" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(to: people(:user_one), from: people(:user_two))
    post connection_requests_path, params: { connection_request: { to: { email: people(:user_two).email } } }
    assert_match "You are already connected to", flash[:warning]
    assert_redirected_to connections_path
  end
  test "connection request when the to person has an account" do
    connection_request_email_spy_was_called = false
    connection_request_email_mock = Minitest::Mock.new
    connection_request_email_mock.expect :deliver_now, true
    connection_request_email_spy = lambda do |from, to|
      connection_request_email_spy_was_called = true
      assert_equal people(:user_one), from
      assert_equal people(:user_two), to
      connection_request_email_mock
    end
    ConnectionMailer.stub :connection_request_email, connection_request_email_spy do
      post connection_requests_path, params: { connection_request: { to: { email: people(:user_two).email } } }
      assert ConnectionRequest.where(from: people(:user_one), to: people(:user_two)).exists?
      assert_match (/Connection with.*requested/), flash[:info]
      assert_redirected_to connections_path
      assert connection_request_email_spy_was_called
      connection_request_email_mock.verify
    end
  end
  test "connection request when the to person doesn't have an account" do
    signup_request_email_spy_was_called = false
    signup_request_email_mock = Minitest::Mock.new
    signup_request_email_mock.expect :deliver_now, true
    signup_request_email_spy = lambda do |from, to|
      signup_request_email_spy_was_called = true
      assert_equal people(:user_one), from
      assert_equal "other.person@example.com", to
      signup_request_email_mock
    end
    ConnectionMailer.stub :signup_request_email, signup_request_email_spy do
      post connection_requests_path, params: { connection_request: { to: { email: "other.person@example.com" } } }
      assert SignupRequest.where(from: people(:user_one), to: "other.person@example.com").exists?
      assert_match "There is no account associated with", flash[:info]
      assert_redirected_to connections_path
      assert signup_request_email_spy_was_called
      signup_request_email_mock.verify
    end
  end
end

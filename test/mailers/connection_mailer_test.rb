require "test_helper"

class ConnectionMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers
  test "signup_request_email" do
    mail = ConnectionMailer.signup_request_email(people(:user_one), "joe@example.com")
    assert_equal "Request from #{people(:user_one).name} to Connect", mail.subject
    assert_equal [ "joe@example.com" ], mail.to
    assert_equal [ "administrator@bentleyneeds.money" ], mail.from
    assert_match new_person_registration_url(host: "localhost", port: 3000), mail.body.encoded
  end

  test "connection_request_email" do
    mail = ConnectionMailer.connection_request_email(people(:user_one), people(:user_two))
    assert_equal "Request from #{people(:user_one).name} to Connect", mail.subject
    assert_equal [ people(:user_two).email ], mail.to
    assert_equal [ "administrator@bentleyneeds.money" ], mail.from
    assert_match connections_url(host: "localhost", port: 3000), mail.body.encoded
  end
end

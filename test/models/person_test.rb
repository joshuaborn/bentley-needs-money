require "test_helper"

class PersonTest < ActiveSupport::TestCase
   test "should not save without a name" do
      assert_not Person.new.save, "saved the person without a name"
   end

   test "request_connection to email of a person already connected just returns that connection" do
      person = people(:user_one)
      preexisting_connection = person.connections.create!(to: people(:user_two))
      assert_not_nil preexisting_connection
      assert_equal preexisting_connection, people(:user_one).connections.first
      return_value = person.request_connection(people(:user_two).email)
      assert_equal preexisting_connection, return_value
   end

   test "request_connection to email of a person with an account creates and returns a ConnectionRequest" do
      person = people(:user_one)
      return_value = person.request_connection(people(:user_two).email)
      assert_equal ConnectionRequest, return_value.class
      assert_equal person, return_value.from
      assert_equal people(:user_two), return_value.to
   end

   test "request_connection to email not associated with an account creates and returns a SignupRequest" do
      person = people(:user_one)
      return_value = person.request_connection("unregistered.email@example.com")
      assert_equal SignupRequest, return_value.class
      assert_equal person, return_value.from
      assert_equal "unregistered.email@example.com", return_value.to
   end

   test "is_connected_with?" do
      Connection.create(from: people(:user_one), to: people(:user_two))
      assert people(:user_one).is_connected_with?(people(:user_one))
      assert people(:user_one).is_connected_with?(people(:user_two))
      assert_not people(:user_one).is_connected_with?(people(:user_three))
   end
end

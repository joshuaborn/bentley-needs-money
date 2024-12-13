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

   test "don't create duplicate ConnectionRequests" do
      person = people(:user_one)
      ConnectionRequest.create(from: person, to: people(:user_two))
      assert_no_difference "ConnectionRequest.count" do
         return_value = person.request_connection(people(:user_two).email)
         assert_equal ConnectionRequest, return_value.class
         assert_equal person, return_value.from
         assert_equal people(:user_two), return_value.to
      end
   end

   test "request_connection to email not associated with an account creates and returns a SignupRequest" do
      person = people(:user_one)
      return_value = person.request_connection("unregistered.email@example.com")
      assert_equal SignupRequest, return_value.class
      assert_equal person, return_value.from
      assert_equal "unregistered.email@example.com", return_value.to
   end

   test "don't create duplicate SignupRequests" do
      person = people(:user_one)
      SignupRequest.create(from: person, to: "unregistered.email@example.com")
      assert_no_difference "SignupRequest.count" do
         return_value = person.request_connection("unregistered.email@example.com")
         assert_equal SignupRequest, return_value.class
         assert_equal person, return_value.from
         assert_equal "unregistered.email@example.com", return_value.to
      end
   end

   test "is_connected_with?" do
      Connection.create(from: people(:user_one), to: people(:user_two))
      assert people(:user_one).is_connected_with?(people(:user_one))
      assert people(:user_one).is_connected_with?(people(:user_two))
      assert_not people(:user_one).is_connected_with?(people(:user_three))
   end

   test "conversion of SignupRequest to ConnectionRequest on account creation" do
      email_address = "joe.schmoe@example.com"
      sr1 = SignupRequest.create(from: people(:user_one), to: email_address)
      sr2 = SignupRequest.create(from: people(:user_three), to: email_address)
      sr3 = SignupRequest.create(from: people(:user_two), to: "jill.bill@example.com")
      new_person = Person.new(name: "Joe Schmoe", email: email_address, password: "password")
      assert new_person.confirm
      assert new_person.save!
      assert SignupRequest.where(id: sr1.id).empty?
      assert SignupRequest.where(id: sr2.id).empty?
      assert SignupRequest.where(id: sr3.id).exists?
      assert ConnectionRequest.where(from: people(:user_one), to: new_person).exists?
      assert ConnectionRequest.where(from: people(:user_three), to: new_person).exists?
      assert ConnectionRequest.where(from: people(:user_two), to: new_person).empty?
   end
end

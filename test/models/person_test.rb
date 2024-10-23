require "test_helper"

class PersonTest < ActiveSupport::TestCase
   test "should not save without a name" do
      assert_not Person.new.save, "saved the person without a name"
   end
   test "cannot delete last administrator" do
      assert_equal 1, Person.where(is_administrator: true).count
      administrator = Person.where(is_administrator: true).first
      assert_no_difference("Person.count") do
         assert_raises do
            administrator.destroy
         end
      end
   end
end

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
   test "getting a list of people and the money owed" do
      srand(9192031)
      build_expenses_for_tests()
      person = people(:user_one)
      amounts_owed = person.get_amounts_owed()
      assert_equal people(:administrator).id, amounts_owed[0].person_id
      assert_equal people(:administrator).name, amounts_owed[0].name
      assert_equal 447.61, amounts_owed[0].dollar_cumulative_sum
      assert_equal people(:user_two).id, amounts_owed[1].person_id
      assert_equal people(:user_two).name, amounts_owed[1].name
      assert_equal 561.11, amounts_owed[1].dollar_cumulative_sum
   end
end

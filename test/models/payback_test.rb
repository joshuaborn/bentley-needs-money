require "test_helper"

class PaybackTest < ActiveSupport::TestCase
  test "amount_owed returns positive value if current_person is owed money" do
    build_expenses_for_tests()
    assert_equal 326, Payback.amount_owed(people(:user_one), people(:user_two))
  end
  test "amount_owed returns negative value if current_person owes money" do
    build_expenses_for_tests()
    assert_equal (-326), Payback.amount_owed(people(:user_two), people(:user_one))
  end
end

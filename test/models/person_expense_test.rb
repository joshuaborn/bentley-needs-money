require "test_helper"

class PersonExpenseTest < ActiveSupport::TestCase
  test "getting amount in dollars" do
    assert_equal 7.31, PersonExpense.new(amount: 731).dollar_amount
  end
  test "setting amount in dollars" do
    assert_equal 731, PersonExpense.new(dollar_amount: 7.31).amount
  end
  test "getting PersonExpense records for a given person that are with specified other person" do
    srand(9192024)
    build_expenses_for_tests()
    person_expenses = PersonExpense.find_for_person_with_other_person(people(:user_one), people(:user_two))
    person_expenses.each do |person_expense|
      assert_equal people(:user_one), person_expense.person
    end
    assert_equal 4, person_expenses.length
    assert_equal -56111, person_expenses.inject(0) { |sum, expense| sum + expense.amount }
  end
  test "when a PersonExpense is first created between two people, the amount owed becomes the cumulative sum" do
    Expense.split_between_two_people("2024-09-21", people(:user_one), people(:user_two), 6.52).save!
    assert_equal 1, people(:user_one).person_expenses.count
    assert_equal 326, people(:user_one).person_expenses.first.cumulative_sum
    assert_equal 1, people(:user_two).person_expenses.count
    assert_equal (-326), people(:user_two).person_expenses.first.cumulative_sum
  end
end

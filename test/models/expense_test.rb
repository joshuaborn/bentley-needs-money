require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  test "Expense should not validate without at least two valid PersonExpenses" do
    expense = Expense.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 10.00
    )
    assert_not expense.valid?
    assert_includes expense.errors.messages[:person_expenses], "is too short (minimum is 2 characters)"

    expense = Expense.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 11.00
    )
    expense.person_expenses.new(person: people(:user_one), dollar_amount: 5.50)
    assert_not expense.valid?
    assert_includes expense.errors.messages[:person_expenses], "is too short (minimum is 2 characters)"

    expense = Expense.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 11.00
    )
    expense.person_expenses.new(person: people(:user_one), dollar_amount: 5.50)
    expense.person_expenses.new(person: people(:user_two), dollar_amount: -5.50)
    assert expense.valid?
    assert_not_includes expense.errors.messages[:person_expenses], "is too short (minimum is 2 characters)"

    expense = Expense.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 11.00
    )
    expense.person_expenses.new(person: people(:user_one), dollar_amount: 5.50)
    expense.person_expenses.new(person: people(:user_two))
    assert_not expense.valid?
    assert_includes expense.errors.messages[:person_expenses], "is invalid"
  end
  test "getting amount_paid in dollars" do
    assert_equal 7.31, Expense.new(amount_paid: 731).dollar_amount_paid
  end
  test "setting amount_paid in dollars" do
    assert_equal 731, Expense.new(dollar_amount_paid: "7.31").amount_paid
  end
  test "creating an Expense by splitting between two people" do
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-24",
      dollar_amount_paid: 10.00
    )
    expense.save!
    assert_equal 1000, expense.amount_paid
    assert_equal 10.00, expense.dollar_amount_paid
    assert_equal 5.00, expense.person_expenses.where(person: people(:user_one)).first.dollar_amount
    assert expense.person_expenses.where(person: people(:user_one)).first.in_ynab
    assert_equal (-5.00), expense.person_expenses.where(person: people(:user_two)).first.dollar_amount
    assert_not expense.person_expenses.where(person: people(:user_two)).first.in_ynab
    srand(9192024)
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 7.31
    )
    expense.save!
    assert_equal 731, expense.amount_paid
    assert_equal 7.31, expense.dollar_amount_paid
    assert_equal 3.66, expense.person_expenses.where(person: people(:user_one)).first.dollar_amount
    assert expense.person_expenses.where(person: people(:user_one)).first.in_ynab
    assert_equal (-3.65), expense.person_expenses.where(person: people(:user_two)).first.dollar_amount
    assert_not expense.person_expenses.where(person: people(:user_two)).first.in_ynab
    srand(9192027)
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-26",
      dollar_amount_paid: 7.31
    )
    expense.save!
    assert_equal 731, expense.amount_paid
    assert_equal 7.31, expense.dollar_amount_paid
    assert_equal 3.65, expense.person_expenses.where(person: people(:user_one)).first.dollar_amount
    assert expense.person_expenses.where(person: people(:user_one)).first.in_ynab
    assert_equal (-3.66), expense.person_expenses.where(person: people(:user_two)).first.dollar_amount
    assert_not expense.person_expenses.where(person: people(:user_two)).first.in_ynab
  end
  test "getting all and only expenses split between two people" do
    build_expenses_for_tests()
    expenses = Expense.find_between_two_people(people(:user_one), people(:user_two))
    assert_equal 4, expenses.length
    assert_equal 115303, expenses.inject(0) { |sum, expense| sum + expense.amount_paid }
  end
  test "creating Expense record and corresponding PersonExpense records with dollar amount" do
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-26",
      dollar_amount_paid: 7.31,
      memo: "widgets"
    )
    assert_equal Date.new(2024, 9, 26), expense.date
    assert_equal 731, expense.amount_paid
    assert_equal "Acme, Inc.", expense.payee
    assert_equal "widgets", expense.memo
  end
  test "creating Expense record and corresponding PersonExpense records with cents amount" do
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-26",
      amount_paid: 731,
      memo: "widgets"
    )
    assert_equal Date.new(2024, 9, 26), expense.date
    assert_equal 731, expense.amount_paid
    assert_equal "Acme, Inc.", expense.payee
    assert_equal "widgets", expense.memo
  end
  test "validation that absolute values of amounts on person_transactions sum to amount_paid and amounts sum to zero" do
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-26",
      dollar_amount_paid: 7.31,
      memo: "widgets"
    )
    assert expense.valid?
    expense.person_expenses.first.amount = 1
    assert_not expense.valid?
    assert_includes expense.errors.messages[:dollar_amount_paid], "should be the sum of the amounts split between people"
    assert_includes expense.errors.messages[:person_expenses], "amounts should sum to zero"
  end
end

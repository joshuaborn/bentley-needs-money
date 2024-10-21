require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
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
    assert_equal 5.00, expense.person_transfers.where(person: people(:user_one)).first.dollar_amount
    assert expense.person_transfers.where(person: people(:user_one)).first.in_ynab
    assert_equal (-5.00), expense.person_transfers.where(person: people(:user_two)).first.dollar_amount
    assert_not expense.person_transfers.where(person: people(:user_two)).first.in_ynab
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
    assert_equal 3.66, expense.person_transfers.where(person: people(:user_one)).first.dollar_amount
    assert expense.person_transfers.where(person: people(:user_one)).first.in_ynab
    assert_equal (-3.65), expense.person_transfers.where(person: people(:user_two)).first.dollar_amount
    assert_not expense.person_transfers.where(person: people(:user_two)).first.in_ynab
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
    assert_equal 3.65, expense.person_transfers.where(person: people(:user_one)).first.dollar_amount
    assert expense.person_transfers.where(person: people(:user_one)).first.in_ynab
    assert_equal (-3.66), expense.person_transfers.where(person: people(:user_two)).first.dollar_amount
    assert_not expense.person_transfers.where(person: people(:user_two)).first.in_ynab
  end
  test "creating Expense record and corresponding person_transfer records with dollar amount" do
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
  test "creating Expense record and corresponding person_transfer records with cents amount" do
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
    expense.person_transfers.first.amount = 1
    assert_not expense.valid?
    assert_includes expense.errors.messages[:dollar_amount_paid], "should be the sum of the amounts split between people"
    assert_includes expense.errors.messages[:person_transfers], "amounts should sum to zero"
  end
end

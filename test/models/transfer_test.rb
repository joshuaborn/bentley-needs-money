require "test_helper"

class TransferTest < ActiveSupport::TestCase
  test "should not validate without at least two valid transfer_expenses" do
    expense = Transfer.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 10.00
    )
    assert_not expense.valid?
    assert_includes expense.errors.messages[:person_transfers], "is too short (minimum is 2 characters)"

    expense = Transfer.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 11.00
    )
    expense.person_transfers.new(person: people(:user_one), dollar_amount: 5.50)
    assert_not expense.valid?
    assert_includes expense.errors.messages[:person_transfers], "is too short (minimum is 2 characters)"

    expense = Transfer.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 11.00
    )
    expense.person_transfers.new(person: people(:user_one), dollar_amount: 5.50)
    expense.person_transfers.new(person: people(:user_two), dollar_amount: -5.50)
    assert expense.valid?
    assert_not_includes expense.errors.messages[:person_transfers], "is too short (minimum is 2 characters)"

    expense = Transfer.new(
      payee: "Acme, Inc.",
      date: "2024-09-25",
      dollar_amount_paid: 11.00
    )
    expense.person_transfers.new(person: people(:user_one), dollar_amount: 5.50)
    expense.person_transfers.new(person: people(:user_two))
    assert_not expense.valid?
    assert_includes expense.errors.messages[:person_transfers], "is invalid"
  end
  test "getting amount_paid in dollars" do
    assert_equal 7.31, Transfer.new(amount_paid: 731).dollar_amount_paid
  end
  test "setting amount_paid in dollars" do
    assert_equal 731, Transfer.new(dollar_amount_paid: "7.31").amount_paid
  end
end

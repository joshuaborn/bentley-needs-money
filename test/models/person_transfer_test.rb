require "test_helper"

class PersonTransferTest < ActiveSupport::TestCase
  test "getting amount in dollars" do
    assert_equal 7.31, PersonTransfer.new(amount: 731).dollar_amount
  end
  test "setting amount in dollars" do
    assert_equal 731, PersonTransfer.new(dollar_amount: 7.31).amount
  end
  test "getting PersonTransfer records for a given person that are with specified other person" do
    srand(9192024)
    build_expenses_for_tests()
    person_transfers = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two))
    person_transfers.each do |person_transfer|
      assert_equal people(:user_one), person_transfer.person
    end
    assert_equal 4, person_transfers.length
    assert_equal (-56111), person_transfers.inject(0) { |sum, expense| sum + expense.amount }
  end
  test "getting of PersonTransfer associated with other Person" do
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-21",
      dollar_amount_paid: 6.52
    )
    this_person_transfer = expense.person_transfers.detect { |person_transfer| person_transfer.person_id == people(:user_one).id }
    assert_equal people(:user_one), this_person_transfer.person
    expense.save!
    assert_equal people(:user_two), this_person_transfer.other_person
  end
  test "getting of Person associated Expense associated with this PersonTransfer" do
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-21",
      dollar_amount_paid: 6.52
    )
    this_person_transfer = expense.person_transfers.detect { |person_transfer| person_transfer.person_id == people(:user_one).id }
    assert_equal people(:user_one), this_person_transfer.person
    expense.save!
    other_person = this_person_transfer.other_person()
    assert_equal people(:user_two), other_person
  end
  test "when a PersonTransfer is first created between two people, the amount owed becomes the cumulative sum" do
    Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-21",
      dollar_amount_paid: 6.52
    ).save!
    assert_equal 1, people(:user_one).person_transfers.count
    assert_equal 326, people(:user_one).person_transfers.first.cumulative_sum
    assert_equal 1, people(:user_two).person_transfers.count
    assert_equal (-326), people(:user_two).person_transfers.first.cumulative_sum
  end
  test "when a PersonTransfer is created, its cumulative_sum is set to the sum of the previous PersonTransfer's cumulative_sum and this PersonTransfer's amount" do
    srand(9192031)
    build_expenses_for_tests()
    person_transfers = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two))
    assert_equal 326, person_transfers[0].cumulative_sum
    assert_equal 770, person_transfers[1].cumulative_sum
    assert_equal (-4491), person_transfers[2].cumulative_sum
    assert_equal (-56112), person_transfers[3].cumulative_sum
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-26",
      dollar_amount_paid: 10.00
    )
    expense.save!
    person_transfer = expense.person_transfers.where(person: people(:user_one)).first
    assert_equal (-55612), person_transfer.cumulative_sum
  end
  test "when a PersonTransfer is created before another, each's cumulative_sum is set appropriately" do
    srand(9192031)
    build_expenses_for_tests()
    Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-20",
      dollar_amount_paid: 10.00
    ).save!
    person_transfers = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two))
    assert_equal 326, person_transfers[0].cumulative_sum
    assert_equal 826, person_transfers[1].cumulative_sum
    assert_equal 1270, person_transfers[2].cumulative_sum
    assert_equal (-3991), person_transfers[3].cumulative_sum
    assert_equal (-55612), person_transfers[4].cumulative_sum
  end
  test "when a PersonTransfer is created before all others, its cumulative_sum is set to its own amount" do
    srand(9192031)
    build_expenses_for_tests()
    Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-01-01",
      dollar_amount_paid: 2.00
    ).save!
    person_transfers = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two))
    assert_equal 100, person_transfers[0].cumulative_sum
    assert_equal 426, person_transfers[1].cumulative_sum
    assert_equal 870, person_transfers[2].cumulative_sum
    assert_equal (-4391), person_transfers[3].cumulative_sum
    assert_equal (-56012), person_transfers[4].cumulative_sum
  end
  test "when a PersonTransfer is updated, its cumulative_sum is set to the sum of the previous PersonTransfer's cumulative_sum and this PersonTransfer's amount" do
    srand(9192031)
    build_expenses_for_tests()
    person_transfers = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two))
    assert_equal 326, person_transfers[0].cumulative_sum
    assert_equal 770, person_transfers[1].cumulative_sum
    assert_equal (-4491), person_transfers[2].cumulative_sum
    assert_equal (-56112), person_transfers[3].cumulative_sum
    person_transfers[2].update(dollar_amount: -42.61)
    assert_equal (-3491), person_transfers[2].cumulative_sum
  end
  test "getting cumulative_sum in dollars" do
    srand(9192031)
    expense = Expense.split_between_two_people(
      people(:user_one),
      people(:user_two),
      payee: "Acme, Inc.",
      date: "2024-09-21",
      dollar_amount_paid: 6.51
    )
    expense.save!
    assert_equal (-3.26), expense.person_transfers.last.dollar_cumulative_sum
    assert_equal 3.25, expense.person_transfers.first.dollar_cumulative_sum
  end
  test "getting a list of people and the money owed" do
     srand(9192031)
     build_expenses_for_tests()
     amounts_owed = PersonTransfer.get_amounts_owed_for(people(:user_one))
     assert_equal people(:administrator).id, amounts_owed[0].person_id
     assert_equal people(:administrator).name, amounts_owed[0].name
     assert_equal 447.61, amounts_owed[0].dollar_cumulative_sum
     assert_equal people(:user_two).id, amounts_owed[1].person_id
     assert_equal people(:user_two).name, amounts_owed[1].name
     assert_equal 561.11, amounts_owed[1].dollar_cumulative_sum
  end
end

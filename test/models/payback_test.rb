require "test_helper"

class PaybackTest < ActiveSupport::TestCase
  test "create a Payback record from payer, payee, and amount parameters" do
    srand(9192031)
    build_expenses_for_tests()
    Payback.new_from_parameters(
      people(:user_one),
      people(:administrator),
      {
        date: "2024-09-25",
        dollar_amount_paid: "447.61"
      }
    ).save!
    person_transfer = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:administrator)).last
    assert_equal 447.61, person_transfer.dollar_amount
    assert_equal 447.61, person_transfer.transfer.dollar_amount_paid
    other_person_transfer = person_transfer.transfer.person_transfers.find_by_person_id(people(:administrator).id)
    assert_equal (-447.61), other_person_transfer.dollar_amount
  end
end

require "test_helper"

class TransfersHelperTest < ActionView::TestCase
  test "grouping of transfers by date" do
    build_expenses_for_tests()
    person_transfers = people(:user_one).person_transfers.includes(:transfer, :person_transfers, :people).order(transfers: { date: :desc })
    hashed_person_transfers = group_by_date(person_transfers)
    assert hashed_person_transfers.is_a? Hash
    assert_equal 5, hashed_person_transfers.length
    assert_equal "09/24/2024", hashed_person_transfers.keys.first
  end
end

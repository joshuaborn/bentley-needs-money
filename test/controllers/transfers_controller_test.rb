require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
    people(:user_five).confirm
  end
  test "#index" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    connected_people = [ people(:administrator), people(:user_three), people(:user_five) ]
    connected_people.each do |other_person|
      Connection.create(from: people(:user_one), to: other_person)
    end
    react_json = {
      "connected.people": connected_people.map do |person|
        { "id": person.id, "name": person.name }
      end,
      "person.transfers": people(:user_one).person_transfers.
        includes(:transfer, :person_transfers, :people).
        order(transfers: { date: :desc, created_at: :asc }). map do |person_transfer|
          {
            "date" => person_transfer.transfer.date,
            "dollarAmountPaid" => person_transfer.transfer.dollar_amount_paid,
            "memo" => person_transfer.transfer.memo,
            "myPersonTransfer" => {
              "dollarAmount" => person_transfer.dollar_amount,
              "id" => person_transfer.id,
              "inYnab" => person_transfer.in_ynab?,
              "personId" => people(:user_one).id
            },
            "otherPersonTransfers" => [
              {
                "cumulativeSum" => person_transfer.dollar_cumulative_sum,
                "date" => person_transfer.transfer.date,
                "dollarAmount" => person_transfer.other_person_transfer.dollar_amount,
                "id" => person_transfer.other_person_transfer.id,
                "name" => person_transfer.other_person.name,
                "personId" => person_transfer.other_person.id
              }
            ],
            "payee" => person_transfer.transfer.payee,
            "transferId" => person_transfer.transfer_id,
            "type" => person_transfer.transfer.type
          }
        end
    }.to_json
    get transfers_path
    assert_response :success
    dom_element = css_select("#transfers-index-app").first
    assert_equal JSON.parse(react_json)["connected.people"], JSON.parse(dom_element["data-for-react"])["connected.people"]
    assert_equal JSON.parse(react_json)["person.transfers"], JSON.parse(dom_element["data-for-react"])["person.transfers"]
  end
  test "flash message when there are connection requests to accept or deny" do
    build_expenses_for_tests()
    ConnectionRequest.create(from: people(:user_two), to: people(:user_one))
    sign_in people(:user_one)
    get transfers_path
    assert_response :success
    assert_match "You have one or more connection requests.", flash[:info]
  end
  test "redirect to connections index when there are no transfers, no connections, and no connection requests" do
    sign_in people(:user_five)
    get transfers_path
    assert_redirected_to connections_path
    assert_equal "In order to begin, you need a connection with another person. Request a connection so that you can start splitting expenses.", flash[:info]
  end
  test "redirect to connections index when there are no transfers and no connections, but a connection request" do
    ConnectionRequest.create(from: people(:user_two), to: people(:user_five))
    sign_in people(:user_five)
    get transfers_path
    assert_redirected_to connections_path
    assert_equal "In order to begin, you need a connection with another person. You already have someone who has requested to connect with you, so you can accept the request to start splitting expenses.", flash[:info]
  end
end

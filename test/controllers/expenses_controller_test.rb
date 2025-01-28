require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
  end
  test "#create when current_user paid and is splitting with other person" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    sign_in people(:user_one)
    parameters = {
      person_paid: "current",
      person: { id: people(:user_two).id },
      expense: {
        payee: "Acme, Inc.",
        memo: "widgets",
        date: "2024-09-25",
        dollar_amount_paid: "4.3"
      }
    }
    post expenses_path, params: parameters, as: :json
    assert_response :success
    person_transfers = people(:user_one).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
  end
  test "#create when other person paid and is splitting with current_user" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    sign_in people(:user_one)
    parameters = {
      person_paid: "other",
      person: { id: people(:user_two).id },
      expense: {
        payee: "Acme, Inc.",
        memo: "widgets",
        date: "2024-09-25",
        dollar_amount_paid: "4.3"
      }
    }
    post expenses_path, params: parameters, as: :json
    assert_response :success
    person_transfers = people(:user_one).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
  end
  test "#create re-renders new when there are validation errors" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    person = people(:user_one)
    sign_in person
    connected_people = [ people(:administrator), people(:user_three), people(:user_five) ]
    connected_people.each do |other_person|
      Connection.create(from: person, to: other_person)
    end
    parameters = {
      person_paid: "other",
      person: { id: people(:user_two).id },
      expense: {
        memo: "widgets",
        date: "2024-09-25",
        dollar_amount_paid: "4.3"
      }
    }
    assert_no_difference("Expense.count") do
      post expenses_path, params: parameters
    end
    expected_response = { "expense.payee"=>[ "can't be blank" ] }
    assert_equal JSON.parse(expected_response.to_json), @response.parsed_body["expense.errors"]
  end
  test "#create raises an error person_paid parameter is invalid on create" do
    Connection.create(from: people(:user_one), to: people(:user_two))
    sign_in people(:user_one)
    parameters = {
      person_paid: "foobar",
      person: { id: people(:user_two).id },
      expense: {
        payee: "Acme, Inc.",
        memo: "widgets",
        date: "2024-09-25",
        dollar_amount_paid: "4.3"
      }
    }
    assert_no_difference("Expense.count") do
      assert_raises(StandardError) do
        post expenses_path, params: parameters
      end
    end
  end
  test "#create returns a 404 not found response when the other perosn is not one of the connected_people" do
    sign_in people(:user_one)
    parameters = {
      person_paid: "other",
      person: { id: people(:user_two).id },
      expense: {
        payee: "Acme, Inc.",
        memo: "widgets",
        date: "2024-09-25",
        dollar_amount_paid: "4.3"
      }
    }
    assert_no_difference("Expense.count") do
      post expenses_path, params: parameters
    end
    assert_response :missing
  end
  test "#update expenses and associated person_transfers" do
    sign_in people(:user_one)
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    build_expenses_for_tests()
    person_transfer = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two)).last
    parameters = {
      "expense": {
        "date": "2025-01-24",
        "dollar_amount_paid": 9,
        "memo": "Memo 9",
        "payee": "Payee 9"
      },
      "my_person_transfer": {
        "dollar_amount": 4.5,
        "id": person_transfer.id,
        "in_ynab": true
      },
      "other_person_transfers": [
        {
          "dollar_amount": -4.5,
          "id": person_transfer.other_person_transfer.id,
          "in_ynab": true
        }
      ]
    }
    assert_no_difference("Expense.count") do
      patch expense_path(person_transfer.transfer.id), params: parameters, as: :json
    end
    assert_response :success
    person_transfers = people(:user_one).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
    person_transfer.reload
    assert_equal parameters[:expense][:date], person_transfer.transfer.date.to_s
    assert_equal parameters[:expense][:dollar_amount_paid], person_transfer.transfer.dollar_amount_paid
    assert_equal parameters[:expense][:memo], person_transfer.transfer.memo
    assert_equal parameters[:expense][:payee], person_transfer.transfer.payee
    assert_equal parameters[:my_person_transfer][:dollar_amount], person_transfer.dollar_amount
    assert person_transfer.in_ynab
    assert_equal parameters[:other_person_transfers][0][:dollar_amount], person_transfer.other_person_transfer.dollar_amount
    assert person_transfer.other_person_transfer.in_ynab
  end
  test "#update re-rendering edit when there are validation errors" do
    build_expenses_for_tests()
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    sign_in people(:user_one)
    person_transfer = PersonTransfer.find_for_person_with_other_person(people(:user_one), people(:user_two)).last
    parameters = {
      "expense": {
        "date": "2025-01-24",
        "dollar_amount_paid": 0,
        "memo": "Memo 9",
        "payee": "Payee 9"
      },
      "my_person_transfer": {
        "dollar_amount": 4.25,
        "id": person_transfer.id,
        "in_ynab": true
      },
      "other_person_transfers": [
        {
          "dollar_amount": -4.5,
          "id": person_transfer.other_person_transfer.id,
          "in_ynab": true
        }
      ]
    }
    assert_no_difference("Expense.count") do
      patch expense_path(person_transfer.transfer.id), params: parameters, as: :json
    end
    assert_response :success
    expected_response = {
      "my_person_transfer.dollar_amount"=>[ "amounts should sum to zero" ],
      "other_person_transfers.0.dollar_amount"=>[ "amounts should sum to zero" ],
      "expense.dollar_amount_paid"=>[ "must be greater than 0" ]
    }
    assert_equal JSON.parse(expected_response.to_json), @response.parsed_body["expense.errors"]
  end
  test "missing response when trying to #update an expense with a person without a connection" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    person_transfer = PersonTransfer.find_for_person_with_other_person(people(:administrator), people(:user_two)).last
    expense = person_transfer.transfer
    attributes_before = expense.attributes.to_yaml
    parameters = {
      "expense": {
        "date": "2025-01-24",
        "dollar_amount_paid": 9,
        "memo": "Memo 9",
        "payee": "Payee 9"
      },
      "my_person_transfer": {
        "dollar_amount": 4.5,
        "id": person_transfer.id,
        "in_ynab": true
      },
      "other_person_transfers": [
        {
          "dollar_amount": -4.5,
          "id": person_transfer.other_person_transfer.id,
          "in_ynab": true
        }
      ]
    }
    assert_no_difference("Expense.count") do
      patch expense_path(expense.id), params: parameters, as: :json
    end
    assert_response :missing
    assert_equal attributes_before, expense.reload.attributes.to_yaml
  end
  test "#destroy" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    assert_difference("Expense.count", -1) do
      delete expense_path(expense)
    end
    assert_response :success
    person_transfers = people(:user_one).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
  end
  test "#destroy of expense not associated with current_user" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:administrator), people(:user_two)).last
    assert_no_difference("Expense.count") do
      delete expense_path(expense)
    end
    assert_response :missing
  end
end

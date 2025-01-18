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
      order(transfers: { date: :desc, created_at: :asc }).map do |person_transfer|
        {
          "date" => person_transfer.transfer.date,
          "dollarAmount" => person_transfer.dollar_amount,
          "dollarAmountPaid" => person_transfer.transfer.dollar_amount_paid,
          "id" => person_transfer.id,
          "inYnab" => person_transfer.in_ynab?,
          "memo" => person_transfer.transfer.memo,
          "otherPeople" => [
            {
              "cumulativeSum" => person_transfer.dollar_cumulative_sum,
              "date" => person_transfer.transfer.date,
              "dollarAmount" => person_transfer.other_person_transfer.dollar_amount,
              "id" => person_transfer.other_person.id,
              "name" => person_transfer.other_person.name
            }
          ],
          "payee" => person_transfer.transfer.payee,
          "transferId" => person_transfer.transfer_id,
          "type" => person_transfer.transfer.type
        }
      end
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
      order(transfers: { date: :desc, created_at: :asc }).map do |person_transfer|
        {
          "date" => person_transfer.transfer.date,
          "dollarAmount" => person_transfer.dollar_amount,
          "dollarAmountPaid" => person_transfer.transfer.dollar_amount_paid,
          "id" => person_transfer.id,
          "inYnab" => person_transfer.in_ynab?,
          "memo" => person_transfer.transfer.memo,
          "otherPeople" => [
            {
              "cumulativeSum" => person_transfer.dollar_cumulative_sum,
              "date" => person_transfer.transfer.date,
              "dollarAmount" => person_transfer.other_person_transfer.dollar_amount,
              "id" => person_transfer.other_person.id,
              "name" => person_transfer.other_person.name
            }
          ],
          "payee" => person_transfer.transfer.payee,
          "transferId" => person_transfer.transfer_id,
          "type" => person_transfer.transfer.type
        }
      end
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
    post expenses_path, params: parameters
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
    build_expenses_for_tests()
    sign_in people(:user_one)
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    # patch expense_path(expense), params: {
    #  expense: {
    #    dollar_amount_paid: 3.00,
    #    payee: "Expenses Splitting Software Company",
    #    person_transfers_attributes: {
    #      "0": {
    #        id: expense.person_transfers.first.id,
    #        dollar_amount: -1.50
    #      },
    #      "1": {
    #        id: expense.person_transfers.last.id,
    #        dollar_amount: 1.50,
    #        in_ynab: true
    #      }
    #    }
    #  }
    # }
  end
  test "#update re-rendering edit when there are validation errors" do
    build_expenses_for_tests()
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    # patch expense_path(expense), params: {
    #  expense: {
    #    dollar_amount_paid: 0.00,
    #    payee: "Expenses Splitting Software Company",
    #    person_transfers_attributes: {
    #      "0": {
    #        id: expense.person_transfers.first.id,
    #        dollar_amount: -2.50
    #      },
    #      "1": {
    #        id: expense.person_transfers.last.id,
    #        dollar_amount: 2.50
    #      }
    #    }
    #  }
    # }
  end
  test "missing response when trying to #update an expense not associated with current user" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:administrator), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    # patch expense_path(expense), params: {
    #  expense: {
    #    dollar_amount_paid: 3.00,
    #    payee: "Expenses Splitting Software Company",
    #    person_transfers_attributes: {
    #      "0": {
    #        id: expense.person_transfers.first.id,
    #        dollar_amount: -1.50
    #      },
    #      "1": {
    #        id: expense.person_transfers.last.id,
    #        dollar_amount: 1.50
    #      }
    #    }
    #  }
    # }
  end
  test "missing response when trying to #update an expense with a person without a connection" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    # patch expense_path(expense), params: {
    #  expense: {
    #    dollar_amount_paid: 3.00,
    #    payee: "Expenses Splitting Software Company",
    #    person_transfers_attributes: {
    #      "0": {
    #        id: expense.person_transfers.first.id,
    #        dollar_amount: -1.50
    #      },
    #      "1": {
    #        id: expense.person_transfers.last.id,
    #        dollar_amount: 1.50
    #      }
    #    }
    #  }
    # }
  end
  test "#destroy" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    # delete expense_path(expense)
  end
  test "#destroy of expense not associated with current_user" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:administrator), people(:user_two)).last
    # delete expense_path(expense)
  end
end

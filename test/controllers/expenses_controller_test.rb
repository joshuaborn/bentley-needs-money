require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:user_one).confirm
  end
  test "getting #new" do
    sign_in people(:user_one)
    get new_expense_path
    assert_response :success
  end
  test "#new has a list of connected_people with whom to create a new expense" do
    person = people(:user_one)
    sign_in person
    connected_people = [ people(:administrator), people(:user_three), people(:user_five) ]
    connected_people.each do |other_person|
      Connection.create(from: person, to: other_person)
    end
    get new_expense_path
    assert_select "select#person_id option" do |elements|
      connected_people.each_with_index do |person, i|
        assert_equal elements[i].text, person.name
        assert_equal elements[i].attribute("value").value, person.id.to_s
      end
    end
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
    assert_difference("Expense.count") do
      post expenses_path, params: parameters
    end
    assert_equal "Expense was successfully created.", flash[:info]
    parameters[:expense].each do |key, val|
      assert_equal val, Expense.last.send(key).to_s
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
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
    assert_difference("Expense.count") do
      post expenses_path, params: parameters
    end
    assert_equal "Expense was successfully created.", flash[:info]
    parameters[:expense].each do |key, val|
      assert_equal val, Expense.last.send(key).to_s
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
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
    assert_response 422
    assert_select "input#expense_payee.is-danger"
    assert_select "p.help.is-danger", "can't be blank"
    assert_select "select#person_id option" do |elements|
      people(:user_one).connected_people.each_with_index do |person, i|
        assert_equal elements[i].text, person.name
        assert_equal elements[i].attribute("value").value, person.id.to_s
      end
    end
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
  test "#create returns a 404 not found response when hte other perosn is not one of the connected_people" do
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
  test "getting #edit" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    person_transfer = people(:user_one).person_transfers.first
    get edit_expense_path(person_transfer.id)
    assert_response :success
  end
  test "error when trying to #edit a person_transfer that is not of the current user's" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    person_transfer = people(:user_two).person_transfers.first
    get edit_expense_path(person_transfer.id)
    assert_response :missing
  end
  test "#update expenses and associated person_transfers" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 3.00,
          payee: "Expenses Splitting Software Company",
          person_transfers_attributes: {
            "0": {
              id: expense.person_transfers.first.id,
              dollar_amount: -1.50
            },
            "1": {
              id: expense.person_transfers.last.id,
              dollar_amount: 1.50,
              in_ynab: true
            }
          }
        }
      }
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
    expense_after = Expense.find(expense.id)
    assert_equal 3.00, expense_after.dollar_amount_paid
    assert_equal "Expenses Splitting Software Company", expense_after.payee
    assert_equal expense.date, expense_after.date
    person_transfer_0 = PersonTransfer.find(expense.person_transfers.first.id)
    assert_equal expense_after, person_transfer_0.transfer
    assert_equal (-1.50), person_transfer_0.dollar_amount
    person_transfer_1 = PersonTransfer.find(expense.person_transfers.last.id)
    assert_equal expense_after, person_transfer_1.transfer
    assert_equal 1.50, person_transfer_1.dollar_amount
    assert person_transfer_1.in_ynab?
  end
  test "#update re-rendering edit when there are validation errors" do
    build_expenses_for_tests()
    Connection.create(from: people(:user_one), to: people(:user_two))
    Connection.create(from: people(:user_two), to: people(:user_one))
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 0.00,
          payee: "Expenses Splitting Software Company",
          person_transfers_attributes: {
            "0": {
              id: expense.person_transfers.first.id,
              dollar_amount: -2.50
            },
            "1": {
              id: expense.person_transfers.last.id,
              dollar_amount: 2.50
            }
          }
        }
      }
    end
    assert_response 422
    assert_select "input#expense_dollar_amount_paid.is-danger"
    assert_select "p.help.is-danger", "must be greater than 0"
    assert_equal attributes_before, Expense.find(expense.id).attributes.to_yaml
  end
  test "missing response when trying to #update an expense not associated with current user" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:administrator), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 3.00,
          payee: "Expenses Splitting Software Company",
          person_transfers_attributes: {
            "0": {
              id: expense.person_transfers.first.id,
              dollar_amount: -1.50
            },
            "1": {
              id: expense.person_transfers.last.id,
              dollar_amount: 1.50
            }
          }
        }
      }
    end
    assert_equal attributes_before, Expense.find(expense.id).attributes.to_yaml
    assert_response :missing
  end
  test "missing response when trying to #update an expense with a person without a connection" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 3.00,
          payee: "Expenses Splitting Software Company",
          person_transfers_attributes: {
            "0": {
              id: expense.person_transfers.first.id,
              dollar_amount: -1.50
            },
            "1": {
              id: expense.person_transfers.last.id,
              dollar_amount: 1.50
            }
          }
        }
      }
    end
    assert_equal attributes_before, Expense.find(expense.id).attributes.to_yaml
    assert_response :missing
  end
  test "#destroy" do
    build_expenses_for_tests()
    sign_in people(:user_one)
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    assert_difference("Expense.count", -1) do
      delete expense_path(expense)
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
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

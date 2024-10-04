require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    post login_path, params: { person_id: people(:user_one).id }
    get expenses_path
    assert_response :success
  end
  test "should get redirected to logins#new if no one is logged in" do
    get expenses_path
    assert_equal "Please log in to access this page.", flash[:warning]
    assert_redirected_to new_login_url
  end
  test "should get new" do
    post login_path, params: { person_id: people(:user_one).id }
    get new_expense_path
    assert_response :success
  end
  test "should get a list of people with which to create a new transaction who aren't the current user" do
    post login_path, params: { person_id: people(:user_one).id }
    get new_expense_path
    assert_select "select#person_id option" do |elements|
      Person.where.not(id: people(:user_one)).all.each_with_index do |person, i|
        assert_equal elements[i].text, person.name
        assert_equal elements[i].attribute("value").value, person.id.to_s
      end
    end
  end
  test "create when current_user paid and is splitting with other person" do
    post login_path, params: { person_id: people(:user_one).id }
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
    assert_equal "Transaction was successfully created.", flash[:info]
    parameters[:expense].each do |key, val|
      assert_equal val, Expense.last.send(key).to_s
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
  end
  test "create when other person paid and is splitting with current_user" do
    post login_path, params: { person_id: people(:user_one).id }
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
    assert_equal "Transaction was successfully created.", flash[:info]
    parameters[:expense].each do |key, val|
      assert_equal val, Expense.last.send(key).to_s
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
  end
  test "raises an error person_paid parameter is invalid on create" do
    post login_path, params: { person_id: people(:user_one).id }
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
  test "get edit" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:user_one).id }
    person_expense = people(:user_one).person_expenses.first
    get edit_expense_path(person_expense.id)
    assert_response :success
  end
  test "error when trying to edit a PersonExpense that is not of the current user's" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:user_one).id }
    person_expense = people(:user_two).person_expenses.first
    get edit_expense_path(person_expense.id)
    assert_response :missing
  end
  test "update expenses and associated person_expenses" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:user_one).id }
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 3.00,
          payee: "Expenses Splitting Software Company",
          person_expenses_attributes: {
            "0": {
              id: expense.person_expenses.first.id,
              dollar_amount: -1.50
            },
            "1": {
              id: expense.person_expenses.last.id,
              dollar_amount: 1.50
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
    person_expense_0 = PersonExpense.find(expense.person_expenses.first.id)
    assert_equal expense_after, person_expense_0.expense
    assert_equal (-1.50), person_expense_0.dollar_amount
    person_expense_1 = PersonExpense.find(expense.person_expenses.last.id)
    assert_equal expense_after, person_expense_1.expense
    assert_equal 1.50, person_expense_1.dollar_amount
  end
  test "re-render edit when there are validation errors" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:user_one).id }
    expense = Expense.find_between_two_people(people(:user_one), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 4.00,
          payee: "Expenses Splitting Software Company",
          person_expenses_attributes: {
            "0": {
              id: expense.person_expenses.first.id,
              dollar_amount: -1.50
            },
            "1": {
              id: expense.person_expenses.last.id,
              dollar_amount: 1.50
            }
          }
        }
      }
    end
    assert_response 422
    assert_select "input#expense_dollar_amount_paid.is-danger"
    assert_select "p.help.is-danger", "should be the sum of the amounts split between people"
    assert_equal attributes_before, Expense.find(expense.id).attributes.to_yaml
  end
  test "error when trying to update an expense not associated with current user" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:user_one).id }
    expense = Expense.find_between_two_people(people(:administrator), people(:user_two)).last
    attributes_before = expense.attributes.to_yaml
    assert_no_difference("Expense.count") do
      patch expense_path(expense), params: {
        expense: {
          dollar_amount_paid: 3.00,
          payee: "Expenses Splitting Software Company",
          person_expenses_attributes: {
            "0": {
              id: expense.person_expenses.first.id,
              dollar_amount: -1.50
            },
            "1": {
              id: expense.person_expenses.last.id,
              dollar_amount: 1.50
            }
          }
        }
      }
    end
    assert_response :missing
    assert_equal attributes_before, Expense.find(expense.id).attributes.to_yaml
  end
end

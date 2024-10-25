require "test_helper"

class PaybacksControllerTest < ActionDispatch::IntegrationTest
  test "getting #new" do
    post login_path, params: { person_id: people(:user_one).id }
    get new_payback_path
    assert_response :success
  end
  test "#create in which the current_user is paying someone else back" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:user_one).id }
    parameters = {
      person: { id: people(:administrator).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "447.61"
      }
    }
    assert_difference("Payback.count") do
      post paybacks_path, params: parameters
    end
    assert_equal "Payback was successfully created.", flash[:info]
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
  end
  test "#create in which the current_user is being paid back by someone else" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:administrator).id }
    parameters = {
      person: { id: people(:user_one).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "-447.61"
      }
    }
    assert_difference("Payback.count") do
      post paybacks_path, params: parameters
    end
    assert_equal "Payback was successfully created.", flash[:info]
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
  end
  test "getting #edit" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:administrator).id }
    post paybacks_path, params: {
      person: { id: people(:user_one).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "-447.61"
      }
    }
    person_transfer = people(:administrator).person_transfers.last
    get edit_payback_path(person_transfer.id)
    assert_response :success
  end
  test "#update payback and associated person_transfers" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:administrator).id }
    post paybacks_path, params: {
      person: { id: people(:user_one).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "-447.61"
      }
    }
    payback = people(:administrator).paybacks.last
    assert_no_difference("Payback.count") do
      patch payback_path(payback), params: {
        payback: {
          date: "2024-10-25",
          dollar_amount_paid: "-445.46"
        }
      }
    end
    assert_response :success
    assert_select 'turbo-stream[action="refresh"]'
    payback_after = Payback.find(payback.id)
    assert_equal (-445.46), payback_after.dollar_amount_paid
    assert_equal Date.new(2024, 10, 25), payback_after.date
  end
  test "error when trying to #update an expense not associated with current user" do
    build_expenses_for_tests()
    post login_path, params: { person_id: people(:administrator).id }
    post paybacks_path, params: {
      person: { id: people(:user_one).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "-447.61"
      }
    }
    payback = people(:administrator).paybacks.last
    attributes_before = payback.attributes.to_yaml
    post login_path, params: { person_id: people(:user_two).id }
    assert_no_difference("Payback.count") do
      patch payback_path(payback), params: {
        payback: {
          date: "2024-10-25",
          dollar_amount_paid: "-445.46"
        }
      }
    end
    assert_response :missing
    assert_equal attributes_before, Payback.find(payback.id).attributes.to_yaml
  end
end

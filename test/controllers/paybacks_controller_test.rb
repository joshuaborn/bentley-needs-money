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
end

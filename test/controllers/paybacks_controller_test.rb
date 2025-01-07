require "test_helper"

class PaybacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    people(:administrator).confirm
    people(:user_one).confirm
    people(:user_two).confirm
  end
  test "#create in which the current_user is paying someone else back" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:user_one)
    parameters = {
      person: { id: people(:administrator).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "447.61"
      }
    }
    # post paybacks_path, params: parameters
  end
  test "#create in which the current_user is being paid back by someone else" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    parameters = {
      person: { id: people(:user_one).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "-447.61"
      }
    }
    # post paybacks_path, params: parameters
  end
  test "#create with someone the user is not connected to" do
    build_expenses_for_tests()
    sign_in people(:administrator)
    assert_not people(:administrator).is_connected_with?(people(:user_one))
    parameters = {
      person: { id: people(:user_one).id },
      payback: {
        date: "2024-10-24",
        dollar_amount_paid: "-447.61"
      }
    }
    # post paybacks_path, params: parameters
  end
  test "#update payback and associated person_transfers" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    # post paybacks_path, params: {
    #  person: { id: people(:user_one).id },
    #  payback: {
    #    date: "2024-10-24",
    #    dollar_amount_paid: "-447.61"
    #  }
    # }
    # patch payback_path(payback), params: {
    #  payback: {
    #    date: "2024-10-25",
    #    dollar_amount_paid: "-445.46"
    #  }
    # }
  end
  test "error when trying to #update an expense not associated with current user" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    # post paybacks_path, params: {
    #  person: { id: people(:user_one).id },
    #  payback: {
    #    date: "2024-10-24",
    #    dollar_amount_paid: "-447.61"
    #  }
    # }
    payback = people(:administrator).paybacks.last
    attributes_before = payback.attributes.to_yaml
    sign_in people(:user_two)
    # patch payback_path(payback), params: {
    #  payback: {
    #    date: "2024-10-25",
    #    dollar_amount_paid: "-445.46"
    #  }
    # }
  end
  test "#destroy" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    # post paybacks_path, params: {
    #  person: { id: people(:user_one).id },
    #  payback: {
    #    date: "2024-10-24",
    #    dollar_amount_paid: "-447.61"
    #  }
    # }
    payback = people(:administrator).paybacks.last
    # delete payback_path(payback)
  end
  test "#destroy of payback not associated with current_user" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    # post paybacks_path, params: {
    #  person: { id: people(:user_one).id },
    #  payback: {
    #    date: "2024-10-24",
    #    dollar_amount_paid: "-447.61"
    #  }
    # }
    payback = people(:administrator).paybacks.last
    sign_in people(:user_two)
    # delete payback_path(payback)
  end
end

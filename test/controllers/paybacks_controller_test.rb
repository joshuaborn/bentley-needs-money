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
    assert_difference("Payback.count") do
      post paybacks_path, params: parameters, as: :json
    end
    assert_response :success
    person_transfers = people(:user_one).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
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
    assert_difference("Payback.count") do
      post paybacks_path, params: parameters, as: :json
    end
    assert_response :success
    person_transfers = people(:administrator).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
  end
  test "#create when there are validation errors" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:user_one)
    parameters = {
      person: { id: people(:administrator).id },
      payback: {
        date: "",
        dollar_amount_paid: "0"
      }
    }
    assert_no_difference("Payback.count") do
      post paybacks_path, params: parameters, as: :json
    end
    assert_response :success
    expected_response = { "payback.date"=>[ "can't be blank" ] }
    assert_equal JSON.parse(expected_response.to_json), @response.parsed_body["payback.errors"]
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
    assert_no_difference("Payback.count") do
      post paybacks_path, params: parameters, as: :json
    end
    assert_response :missing
  end
  test "#update payback and associated person_transfers" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    payback = Payback.new_from_parameters(people(:administrator), people(:user_one), { date: "2024-10-24", dollar_amount_paid: -447.61 })
    payback.save!
    assert_no_difference("Payback.count") do
      patch payback_path(payback), params: {
        payback: {
          date: "2024-10-25",
          dollar_amount_paid: "-445.46"
        }
      }
    end
    assert_response :success
    payback.reload
    assert_equal "2024-10-25", payback.date.to_s
    assert_equal (-445.46), payback.dollar_amount_paid
    person_transfers = people(:administrator).person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
    assert_equal JSON.parse(person_transfers.to_json), @response.parsed_body["person.transfers"]
  end
  test "#update with validation errors" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    payback = Payback.new_from_parameters(people(:administrator), people(:user_one), { date: "2024-10-24", dollar_amount_paid: -447.61 })
    payback.save!
    assert_no_difference("Payback.count") do
      patch payback_path(payback), params: {
        payback: {
          date: ""
        }
      }
    end
    assert_response :success
    payback.reload
    assert_equal "2024-10-24", payback.date.to_s
    expected_response = { "payback.date"=>[ "can't be blank" ] }
    assert_equal JSON.parse(expected_response.to_json), @response.parsed_body["payback.errors"]
  end
  test "#update a payback not associated with current user" do
    Connection.create(from: people(:user_one), to: people(:administrator))
    Connection.create(from: people(:administrator), to: people(:user_one))
    build_expenses_for_tests()
    sign_in people(:administrator)
    payback = Payback.new_from_parameters(people(:user_one), people(:user_two), { date: "2024-10-24", dollar_amount_paid: -447.61 })
    payback.save!
    sign_in people(:user_two)
    assert_no_difference("Payback.count") do
      patch payback_path(payback), params: {
        payback: {
          date: "2024-10-25",
          dollar_amount_paid: "-445.46"
        }
      }
    end
    assert_response :missing
    payback.reload
    assert_equal "2024-10-24", payback.date.to_s
    assert_equal (-447.61), payback.dollar_amount_paid
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

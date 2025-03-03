require 'rails_helper'
require 'helpers/person_transfer_mapping.rb'
require 'helpers/build_expenses_for_tests.rb'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe ExpensesController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:connected_user) { FactoryBot.create(:person) }
  let(:unconnected_user) { FactoryBot.create(:person) }

  before(:example) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    Connection.create(from: current_user, to: connected_user)
    Connection.create(from: connected_user, to: current_user)
    sign_in current_user
  end

  describe "#create" do
    subject do
      post :create, params: parameters, as: :json
    end

    context "current user paid and is splitting with other connected person" do
      let(:parameters) do
        {
          person_paid: "current",
          person: { id: connected_user.id },
          expense: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount_paid: "4.3"
          }
        }
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "creates an expense" do
        expect { subject }.to change(Expense, :count).by(1)
      end

      it "responds with list of current user's person_transfers" do
        expect(subject.parsed_body["person.transfers"]).to eq(
          current_user.person_transfers.
            includes(:transfer, :person_transfers, :people).
            order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
        )
      end
    end

    context "other connected person paid and is splitting with current user" do
      let(:parameters) do
        {
          person_paid: "other",
          person: { id: connected_user.id },
          expense: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount_paid: "4.3"
           }
         }
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "creates an expense" do
        expect { subject }.to change(Expense, :count).by(1)
      end

      it "responds with list of current user's person_transfers" do
        expect(subject.parsed_body["person.transfers"]).to eq(
          current_user.person_transfers.
            includes(:transfer, :person_transfers, :people).
            order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
        )
      end
    end

    context "validation error" do
      let(:parameters) do
        {
          person_paid: "other",
          person: { id: connected_user.id },
          expense: {
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount_paid: "4.3"
           }
         }
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "doesn't create an expense" do
        expect { subject }.not_to change(Expense, :count)
      end

      it "responds with error message" do
        expect(subject.parsed_body["expense.errors"]).to eq({ "expense.payee"=>[ "can't be blank" ] })
      end
    end

    context "invalid person_paid parameter" do
      let(:parameters) do
        {
          person_paid: "foobar",
          person: { id: connected_user.id },
          expense: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount_paid: "4.3"
          }
        }
      end

      it "returns a 501" do
        expect(subject).to have_http_status(:error)
      end

      it "doesn't create an expense" do
        expect { subject }.not_to change(Expense, :count)
      end
    end

    context "current person isn't connected with other person" do
      let(:parameters) do
        {
          person_paid: "current",
          person: { id: unconnected_user.id },
          expense: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount_paid: "4.3"
          }
        }
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "doesn't create an expense" do
        expect { subject }.not_to change(Expense, :count)
      end
    end
  end

  describe "#update" do
    before(:example) do
      build_expenses_for_tests(current_user, connected_user, unconnected_user)
      patch :update, params: parameters, as: :json
    end

    context "expense associated with current user and no validation errors" do
      let(:person_transfer) do
        PersonTransfer.find_for_person_with_other_person(
          current_user,
          connected_user
        ).last
      end

      let(:parameters) do
        {
          "id": person_transfer.transfer.id,
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
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the transfer" do
        transfer = person_transfer.reload.transfer
        expect(transfer.date.to_s).to eq(parameters[:expense][:date])
        expect(transfer.dollar_amount_paid).to eq(parameters[:expense][:dollar_amount_paid])
        expect(transfer.memo).to eq(parameters[:expense][:memo])
        expect(transfer.payee).to eq(parameters[:expense][:payee])
      end

      it "updates the person_transfer for the current user" do
        person_transfer.reload
        expect(person_transfer.dollar_amount).to eq(parameters[:my_person_transfer][:dollar_amount])
        expect(person_transfer.in_ynab).to eq(parameters[:my_person_transfer][:in_ynab])
      end

      it "updates the person_transfer for the other user" do
        other_person_transfer = person_transfer.reload.other_person_transfer
        expect(other_person_transfer.dollar_amount).to eq(parameters[:other_person_transfers][0][:dollar_amount])
        expect(other_person_transfer.in_ynab).to eq(parameters[:other_person_transfers][0][:in_ynab])
      end

      it "responds with list of current user's person_transfers" do
        person_transfers = current_user.person_transfers.
          includes(:transfer, :person_transfers, :people).
          order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
        expect(response.parsed_body["person.transfers"]).to eq(person_transfers)
      end
    end

    context "validation errors" do
      let(:person_transfer) do
        PersonTransfer.find_for_person_with_other_person(
          current_user,
          connected_user
        ).last
      end

      let(:parameters) do
        {
          "id": person_transfer.transfer.id,
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
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "responds with error messages" do
        expect(response.parsed_body["expense.errors"]).to eq({
          "my_person_transfer.dollar_amount"=>[ "amounts should sum to zero" ],
          "other_person_transfers.0.dollar_amount"=>[ "amounts should sum to zero" ],
          "expense.dollar_amount_paid"=>[ "must be greater than 0" ]
        })
      end
    end

    context "expense with an unconnected user" do
      let(:person_transfer) do
        PersonTransfer.find_for_person_with_other_person(
          current_user,
          unconnected_user
        ).last
      end

      let(:parameters) do
        {
          "id": person_transfer.transfer.id,
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
      end

      it "returns a 404" do
        expect(response).to have_http_status(:missing)
      end

      it "does not update the person_expense and associated expense" do
        person_transfer_attributes_before = person_transfer.attributes
        transfer_attributes_before = person_transfer.transfer.attributes
        expect(person_transfer.reload.attributes).to eq(person_transfer_attributes_before)
        expect(person_transfer.reload.transfer.attributes).to eq(transfer_attributes_before)
      end
    end
  end

  describe "#destroy" do
    subject do
       delete :destroy, params: parameters, as: :json
    end

    let(:parameters) do
      {
        "id": expense.id
      }
    end

    before(:example) do
      build_expenses_for_tests(current_user, connected_user, unconnected_user)
    end

    context "expense associated with current user" do
      let(:expense) do
        Expense.find_between_two_people(current_user, connected_user).last
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "deletes an expense" do
        expect { subject }.to change(Expense, :count).by(-1)
      end
    end

    context "expense not associated with current user" do
      let(:expense) do
        Expense.find_between_two_people(connected_user, unconnected_user).last
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "does not delete an expense" do
        expect { subject }.not_to change(Expense, :count)
      end
    end
  end
end

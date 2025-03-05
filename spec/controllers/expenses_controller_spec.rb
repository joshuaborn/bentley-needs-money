require 'rails_helper'
require 'support/person_transfer_mapping.rb'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe ExpensesController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:connected_user) { FactoryBot.create(:person) }
  let(:unconnected_user) { FactoryBot.create(:person) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    Connection.create(from: current_user, to: connected_user)
    Connection.create(from: connected_user, to: current_user)
    sign_in current_user
  end

  shared_examples "ok status" do
    it "returns a 200" do
      expect(subject).to have_http_status(:ok)
    end
  end

  describe "#create" do
    subject do
      post :create, params: parameters, as: :json
    end

    shared_examples "create expense" do
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

    shared_examples "doesn't create expense" do
      it "doesn't create an expense" do
        expect { subject }.not_to change(Expense, :count)
      end
    end

    context "when current user paid and is splitting with other connected person" do
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

      include_examples "ok status"
      include_examples "create expense"
    end

    context "when other connected person paid and is splitting with current user" do
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

      include_examples "ok status"
      include_examples "create expense"
    end

    context "with a validation error" do
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

      include_examples "ok status"
      include_examples "doesn't create expense"

      it "responds with error message" do
        expect(subject.parsed_body["expense.errors"]).to eq({ "expense.payee"=>[ "can't be blank" ] })
      end
    end

    context "with invalid person_paid parameter" do
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

      include_examples "doesn't create expense"

      it "returns a 501" do
        expect(subject).to have_http_status(:error)
      end
    end

    context "when current person isn't connected with other person" do
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

      include_examples "doesn't create expense"

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end
    end
  end

  describe "#update" do
    context "when expense is associated with current user and no validation errors" do
      let!(:expense) { create_expense_between_people(current_user, connected_user) }
      let(:person_transfer) do
        PersonTransfer.find_for_person_with_other_person(
          current_user,
          connected_user
        ).last
      end
      let(:parameters) do
        {
          "id": expense.id,
          "expense": {
            "date": Date.new(2025, 1, 24),
            "dollar_amount_paid": 9.0,
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

      before { patch :update, params: parameters, as: :json }

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the transfer" do
        expect(expense.reload).to have_attributes(parameters[:expense])
      end

      it "updates the person_transfer for the current user" do
        expect(person_transfer.reload).to have_attributes(parameters[:my_person_transfer])
      end

      it "updates the dollar amount for the person_transfer for the other user" do
        expect(person_transfer.reload.other_person_transfer.dollar_amount).to eq(parameters[:other_person_transfers][0][:dollar_amount])
      end

      it "doesn't update the in_ynab attribute for the person_transfer for the other user" do
        expect(person_transfer.reload.other_person_transfer.in_ynab).to be_falsey
      end

      it "responds with list of current user's person_transfers" do
        person_transfers = current_user.person_transfers.
          includes(:transfer, :person_transfers, :people).
          order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
        expect(response.parsed_body["person.transfers"]).to eq(person_transfers)
      end
    end

    context "with validation errors" do
      let!(:expense) { create_expense_between_people(current_user, connected_user) }
      let(:person_transfer) do
        PersonTransfer.find_for_person_with_other_person(
          current_user,
          connected_user
        ).last
      end
      let(:parameters) do
        {
          "id": expense.id,
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

      before { patch :update, params: parameters, as: :json }

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

    context "when expense is associated with an unconnected user" do
      subject { patch :update, params: parameters, as: :json }
      let!(:expense) { create_expense_between_people(current_user, unconnected_user) }
      let(:person_transfer) do
        PersonTransfer.find_for_person_with_other_person(
          current_user,
          unconnected_user
        ).last
      end
      let(:parameters) do
        {
          "id": expense.id,
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
        expect(subject).to have_http_status(:missing)
      end

      it "does not change the expense's attributes" do
        expect { subject }.not_to change { expense.reload.attributes }
      end

      it "does not change the associated person_transfer's attributes" do
        expect { subject }.not_to change { person_transfer.reload.attributes }
      end

      it "does not update the person_expense and associated expense" do
        person_transfer_attributes_before = person_transfer.attributes
        transfer_attributes_before = expense.attributes
        expect(person_transfer.reload).to have_attributes(person_transfer_attributes_before)
        expect(person_transfer.reload.transfer).to have_attributes(transfer_attributes_before)
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

    context "of an expense associated with current user" do
      let!(:expense) do
        create_expense_between_people(current_user, connected_user)
      end

      include_examples "ok status"

      it "deletes an expense" do
        expect { subject }.to change(Expense, :count).by(-1)
      end
    end

    context "of an expense not associated with current user" do
      let!(:expense) do
        create_expense_between_people(connected_user, unconnected_user)
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

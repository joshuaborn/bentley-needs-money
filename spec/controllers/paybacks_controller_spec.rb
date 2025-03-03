require 'rails_helper'
require 'helpers/person_transfer_mapping.rb'
require 'helpers/build_expenses_for_tests.rb'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe PaybacksController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:connected_user) { FactoryBot.create(:person) }
  let(:unconnected_user) { FactoryBot.create(:person) }

  before(:example) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    Connection.create(from: current_user, to: connected_user)
    Connection.create(from: connected_user, to: current_user)
    build_expenses_for_tests(current_user, connected_user, unconnected_user)
    sign_in current_user
  end

  describe "#create" do
    subject do
      post :create, params: parameters, as: :json
    end

    context "current user is paying other user back" do
      let(:parameters) do
        {
          person: { id: connected_user.id },
          payback: {
            date: "2024-10-24",
            dollar_amount_paid: "447.61"
          }
        }
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "creates a payback" do
        expect { subject }.to change(Payback, :count).by(1)
      end

      it "responds with list of current user's person_transfers" do
        expect(subject.parsed_body["person.transfers"]).to eq(
          current_user.person_transfers.
            includes(:transfer, :person_transfers, :people).
            order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
        )
      end
    end

    context "current user is being paid back by other user" do
      let(:parameters) do
        {
          person: { id: connected_user.id },
          payback: {
            date: "2024-10-24",
            dollar_amount_paid: "-447.61"
          }
        }
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "creates a payback" do
        expect { subject }.to change(Payback, :count).by(1)
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
          person: { id: connected_user.id },
          payback: {
            date: "",
            dollar_amount_paid: "0"
          }
        }
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "doesn't create a payback" do
        expect { subject }.not_to change(Payback, :count)
      end

      it "responds with error message" do
        expect(subject.parsed_body["payback.errors"]).to eq({ "payback.date"=>[ "can't be blank" ] })
      end
    end

    context "current user isn't connected to other user" do
      let(:parameters) do
        {
          person: { id: unconnected_user.id },
          payback: {
            date: "2024-10-24",
            dollar_amount_paid: "-447.61"
          }
        }
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "doesn't create a payback" do
        expect { subject }.not_to change(Payback, :count)
      end
    end
  end

  describe "#update" do
    before(:example) do
      patch :update, params: parameters, as: :json
    end

    context "payback associated with current user and no validation errors" do
      let(:payback) do
        Payback.new_from_parameters(
          connected_user,
          current_user,
          {
            date: "2024-10-24",
            dollar_amount_paid: -447.61
          }
        ).tap { |payback| payback.save! }
      end

      let(:parameters) do
        {
          id: payback.id,
          payback: {
            date: "2024-10-25",
            dollar_amount_paid: -445.46
          }
        }
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "responds with list of current user's person_transfers" do
        expect(response.parsed_body["person.transfers"]).to eq(
          current_user.person_transfers.
            includes(:transfer, :person_transfers, :people).
            order(transfers: { date: :desc, created_at: :desc }).map { |pt| person_transfer_mapping(pt) }
        )
      end

      it "updates payback's attributes" do
        expect(payback.reload.date.to_s).to eq(parameters[:payback][:date])
        expect(payback.reload.dollar_amount_paid).to eq(parameters[:payback][:dollar_amount_paid])
      end
    end

    context "validation errors" do
      let(:payback) do
        Payback.new_from_parameters(
          connected_user,
          current_user,
          {
            date: "2024-10-24",
            dollar_amount_paid: -447.61
          }
        ).tap { |payback| payback.save! }
      end

      let(:parameters) do
        {
          id: payback.id,
          payback: {
            date: ""
          }
        }
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "doesn't update attributes" do
        expect(payback.reload.date.to_s).to eq("2024-10-24")
        expect(payback.reload.dollar_amount_paid).to eq(-447.61)
      end

      it "responds with error message" do
        expect(response.parsed_body["payback.errors"]).to eq({ "payback.date"=>[ "can't be blank" ] })
      end
    end

    context "payback not associated with current user" do
      let(:payback) do
        Payback.new_from_parameters(
          unconnected_user,
          connected_user,
          {
            date: "2024-10-24",
            dollar_amount_paid: -447.61
          }
        ).tap { |payback| payback.save! }
      end

      let(:parameters) do
        {
          id: payback.id,
          payback: {
            date: "2024-10-25",
            dollar_amount_paid: "-445.46"
          }
        }
      end

      it "returns a 404" do
        expect(response).to have_http_status(:missing)
      end

      it "doesn't update attributes" do
        expect(payback.reload.date.to_s).to eq("2024-10-24")
        expect(payback.reload.dollar_amount_paid).to eq(-447.61)
      end
    end
  end

  describe "#destroy" do
    subject do
      delete :destroy, params: parameters, as: :json
    end

    let(:parameters) do
      {
        "id": Payback.last.id
      }
    end

    context "payback associated with current user" do
      before(:each) do
        Payback.new_from_parameters(
          connected_user,
          current_user,
          {
            date: "2024-10-24",
            dollar_amount_paid: -447.61
          }
        ).save!
      end

      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end

      it "deletes a payback" do
        expect { subject }.to change(Payback, :count).by(-1)
      end
    end

    context "payback not associated with current user" do
      before(:each) do
        Payback.new_from_parameters(
          unconnected_user,
          connected_user,
          {
            date: "2024-10-24",
            dollar_amount_paid: -447.61
          }
        ).save!
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "does not delete a payback" do
        expect { subject }.not_to change(Payback, :count)
      end
    end
  end
end

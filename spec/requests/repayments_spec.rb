require 'rails_helper'

RSpec.describe "Repayments", type: :request do
  let(:current_user) { FactoryBot.create(:person) }
  let(:connected_user) { FactoryBot.create(:person) }
  let(:unconnected_user) { FactoryBot.create(:person) }

  before do
    Connection.create(from: current_user, to: connected_user)
    Connection.create(from: connected_user, to: current_user)
    sign_in current_user, scope: :person
  end

  describe "#create" do
    subject(:request) do
      post repayments_path, params: parameters, as: :json
    end

    shared_examples "status ok" do
      it "returns a 200" do
        request
        expect(response).to have_http_status(:ok)
      end
    end

    shared_examples "create repayment" do
      it "creates a repayment" do
        expect { request }.to change(Repayment, :count).by(1)
      end
    end

    shared_examples "don't create repayment" do
      it "doesn't create a repayment" do
        expect { request }.not_to change(Repayment, :count)
      end
    end

    shared_examples "responds with debts" do
      it "responds with list of current user's debts" do
        request
        decorator = DebtDecorator.new.for(current_user)
        expect(response.parsed_body["debts"]).to eq(
          Debt.for_person(current_user).map { |debt| decorator.decorate(debt).as_json }
        )
      end
    end

    context "when current user is paying other user back" do
      let(:parameters) do
        {
          repayer: "self",
          person: { id: connected_user.id },
          repayment: {
            date: "2024-10-24",
            amount: 44761
          }
        }
      end

      include_examples "status ok"
      include_examples "create repayment"
      include_examples "responds with debts"
    end

    context "when current user is being paid back by other user" do
      let(:parameters) do
        {
          repayer: "other person",
          person: { id: connected_user.id },
          repayment: {
            date: "2024-10-24",
            amount: 44761
          }
        }
      end

      include_examples "status ok"
      include_examples "create repayment"
      include_examples "responds with debts"
    end

    context "with a validation error" do
      let(:parameters) do
        {
          repayer: "self",
          person: { id: connected_user.id },
          repayment: {
            date: "",
            amount: 100000
          }
        }
      end

      include_examples "status ok"
      include_examples "don't create repayment"

      it "responds with error message" do
        request
        expect(response.parsed_body["errors"]).to eq({ "date"=>[ "can't be blank" ] })
      end
    end

    context "when current user isn't connected to other user" do
      let(:parameters) do
        {
          repayer: "self",
          person: { id: unconnected_user.id },
          repayment: {
            date: "2024-10-24",
            amount: 44761
          }
        }
      end

      include_examples "don't create repayment"

      it "returns a 404" do
        request
        expect(response).to have_http_status(:missing)
      end
    end
  end

  describe "#update" do
    before do
      patch repayment_path(repayment.id), params: parameters, as: :json
    end

    shared_examples "ok status" do
      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    shared_examples "doesn't update" do
      it "doesn't update attributes" do
        expect(repayment.reload.date.to_s).to eq("2024-10-24")
        expect(repayment.reload.debts.first.amount).to eq(44761)
      end
    end

    context "of a repayment associated with current user and no validation errors" do
      let(:repayment) do
        Repayment.new(
          connected_user,
          current_user,
          {
            date: "2024-10-24",
            amount: 44761
          }
        ).tap(&:save!)
      end
      let(:parameters) do
        {
          id: repayment.id,
          date: "2024-10-25",
          debts_attributes: [
            {
              id: repayment.debts.first.id,
              amount: 44546
            }
          ]
        }
      end

      include_examples "ok status"

      it "responds with list of current user's debts" do
        decorator = DebtDecorator.new.for(current_user)
        expect(response.parsed_body["debts"]).to eq(
          Debt.for_person(current_user).map { |debt| decorator.decorate(debt).as_json }
        )
      end

      it "updates repayment's attributes" do
        expect(repayment.reload.date.to_s).to eq(parameters[:date])
        expect(repayment.reload.debts.first.amount).to eq(parameters[:debts_attributes][0][:amount])
      end
    end

    context "with validation errors" do
      let(:repayment) do
        Repayment.new(
          connected_user,
          current_user,
          {
            date: "2024-10-24",
            amount: 44761
          }
        ).tap(&:save!)
      end
      let(:parameters) do
        {
          id: repayment.id,
          date: ""
        }
      end

      include_examples "ok status"
      include_examples "doesn't update"

      it "responds with error message" do
        expect(response.parsed_body["errors"]).to eq({ "date"=>[ "can't be blank" ] })
      end
    end

    context "of a repayment not associated with current user" do
      let(:repayment) do
        Repayment.new(
          unconnected_user,
          connected_user,
          {
            date: "2024-10-24",
            amount: 44761
          }
        ).tap(&:save!)
      end
      let(:parameters) do
        {
          id: repayment.id,
          date: "2024-10-25",
          debts_attributes: [
            {
              id: repayment.debts.first.id,
              amount: 44546
            }
          ]
        }
      end

      include_examples "doesn't update"

      it "returns a 404" do
        expect(response).to have_http_status(:missing)
      end
    end
  end

  describe "#destroy" do
    subject(:request) do
      delete repayment_path(Repayment.last.id), params: parameters, as: :json
    end
    let(:parameters) do
      {
        "id": Repayment.last.id
      }
    end

    context "of a repayment associated with current user" do
      before(:each) do
        Repayment.new(
          connected_user,
          current_user,
          {
            date: "2024-10-24",
            amount: 44761
          }
        ).tap(&:save!)
      end

      it "returns a 200" do
        request
        expect(response).to have_http_status(:ok)
      end

      it "deletes a repayment" do
        expect { request }.to change(Repayment, :count).by(-1)
      end
    end

    context "of repayment not associated with current user" do
      before(:each) do
        Repayment.new(
          unconnected_user,
          connected_user,
          {
            date: "2024-10-24",
            amount: 44761
          }
        ).tap(&:save!)
      end

      it "returns a 404" do
        request
        expect(response).to have_http_status(:missing)
      end

      it "does not delete a repayment" do
        expect { request }.not_to change(Repayment, :count)
      end
    end
  end
end

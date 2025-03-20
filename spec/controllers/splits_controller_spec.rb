require 'rails_helper'
require 'support/person_transfer_mapping.rb'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe SplitsController, type: :controller do
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

    shared_examples "create split" do
      it "creates an split" do
        expect { subject }.to change(Split, :count).by(1)
      end

      it "responds with list of current user's debts" do
        decorator = DebtDecorator.new.for(current_user)
        expect(subject.parsed_body["debts"]).to eq(
          Debt.for_person(current_user).map { |debt| decorator.decorate(debt).as_json }
        )
      end
    end

    shared_examples "doesn't create split" do
      it "doesn't create a split" do
        expect { subject }.not_to change(Split, :count)
      end
    end

    context "when current user paid and is splitting with other connected person" do
      let(:parameters) do
        {
          owed: 'self',
          person: { id: connected_user.id },
          split: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount: "4.3"
          }
        }
      end

      include_examples "ok status"
      include_examples "create split"
    end

    context "when other connected person paid and is splitting with current user" do
      let(:parameters) do
        {
          owed: 'other person',
          person: { id: connected_user.id },
          split: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount: "4.3"
           }
         }
      end

      include_examples "ok status"
      include_examples "create split"
    end

    context "with a validation error" do
      let(:parameters) do
        {
          owed: 'self',
          person: { id: connected_user.id },
          split: {
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount: "4.3"
           }
         }
      end

      include_examples "ok status"
      include_examples "doesn't create split"

      it "responds with error message" do
        expect(subject.parsed_body["errors"]).to eq({ "payee"=>[ "can't be blank" ] })
      end
    end

    context "with invalid payer parameter" do
      let(:parameters) do
        {
          owed: 'foobar',
          person: { id: connected_user.id },
          split: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount: "4.3"
          }
        }
      end

      include_examples "doesn't create split"

      it "returns a 501" do
        expect(subject).to have_http_status(:error)
      end
    end

    context "when current person isn't connected with other person" do
      let(:parameters) do
        {
          owed: 'self',
          person: { id: unconnected_user.id },
          split: {
            payee: "Acme, Inc.",
            memo: "widgets",
            date: "2024-09-25",
            dollar_amount: "4.3"
          }
        }
      end

      include_examples "doesn't create split"

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end
    end
  end

  describe "#update" do
    context "when split is associated with current user and no validation errors" do
      let!(:split) do
        Split.between_two_people(
          current_user,
          connected_user,
          FactoryBot.attributes_for(:split)
        ).tap do |split|
          split.save!
        end
      end
      let(:parameters) do
        {
          id: split.id,
          date: Date.new(2025, 1, 24),
          payee: "Payee 9",
          memo: "Memo 9",
          dollar_amount: 9.0,
          debts_attributes: [
            {
              id: split.debts.first.id,
              dollar_amount: 4.5,
              owed_reconciled: !split.debts.first.owed_reconciled,
              ower_reconciled: !split.debts.first.ower_reconciled
            }
          ]
        }
      end

      before { patch :update, params: parameters, as: :json }

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the split" do
        expect(split.reload).to have_attributes(parameters.slice(:id, :date, :payee, :memo, :dollar_amount))
      end

      it "updates the amount of the debt of the split" do
        expect(split.reload.debts.first.dollar_amount).to eq(parameters[:debts_attributes].first[:dollar_amount])
      end

      it "doesn't update the owed_reconciled and ower_reconciled attributes on the debt record" do
        expect(split.reload.debts.first.owed_reconciled).to eq(!parameters[:debts_attributes].first[:owed_reconciled])
        expect(split.reload.debts.first.ower_reconciled).to eq(!parameters[:debts_attributes].first[:ower_reconciled])
      end

      it "responds with list of current user's debts" do
        decorator = DebtDecorator.new.for(current_user)
        expect(response.parsed_body["debts"]).to eq(
          Debt.for_person(current_user).map { |debt| decorator.decorate(debt).as_json }
        )
      end
    end

    context "with validation errors" do
      let!(:split) do
        Split.between_two_people(
          current_user,
          connected_user,
          FactoryBot.attributes_for(:split)
        ).tap do |split|
          split.save!
        end
      end
      let(:parameters) do
        {
          id: split.id,
          date: Date.new(2025, 1, 24),
          payee: "",
          memo: "Memo",
          dollar_amount: 9.0,
          debts_attributes: [
            {
              id: split.debts.first.id,
              dollar_amount: -4.5
            }
          ]
        }
      end

      before { patch :update, params: parameters, as: :json }

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "responds with error messages" do
        expect(response.parsed_body["errors"]).to eq({
          "debts" => [ "is invalid" ],
          "debts.amount" => [ "must be greater than 0" ],
          "payee" => [ "can't be blank" ]
        })
      end
    end

    context "when split is associated with an unconnected user" do
      subject { patch :update, params: parameters, as: :json }
      let!(:split) do
        Split.between_two_people(
          current_user,
          unconnected_user,
          FactoryBot.attributes_for(:split)
        ).tap do |split|
          split.save!
        end
      end
      let(:parameters) do
        {
          id: split.id,
          date: Date.new(2025, 1, 24),
          payee: "Payee 9",
          memo: "Memo 9",
          dollar_amount: 9.0,
          debts_attributes: [
            {
              id: split.debts.first.id,
              dollar_amount: 4.5
            }
          ]
        }
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "does not change the split's attributes" do
        expect { subject }.not_to change { split.reload.attributes }
      end

      it "does not change the associated debts's attributes" do
        expect { subject }.not_to change { split.reload.debts.first.attributes }
      end
    end
  end

  describe "#destroy" do
    subject { delete :destroy, params: parameters, as: :json }
    let(:parameters) { { "id": split.id } }

    context "of an split associated with current user" do
      let!(:split) do
        Split.between_two_people(
          current_user,
          connected_user,
          FactoryBot.attributes_for(:split)
        ).tap do |split|
          split.save!
        end
      end

      include_examples "ok status"

      it "deletes an split" do
        expect { subject }.to change(Split, :count).by(-1)
      end
    end

    context "of an split not associated with current user" do
      let!(:split) do
        Split.between_two_people(
          connected_user,
          unconnected_user,
          FactoryBot.attributes_for(:split)
        ).tap do |split|
          split.save!
        end
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "does not delete an split" do
        expect { subject }.not_to change(Split, :count)
      end
    end
  end
end

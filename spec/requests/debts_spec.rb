require 'rails_helper'

RSpec.describe "Debts", type: :request do
  let(:current_user) { FactoryBot.create(:person) }
  let(:other_user) { FactoryBot.create(:person) }

  before do
    sign_in current_user, scope: :person
  end

  describe "#index" do
    context "when there are no debts and no connections" do
      context "and no connection requests" do
        it "redirects to connections#index and sets the flash" do
          get debts_path
          expect(response).to redirect_to controller: :connections, action: :index
          expect(flash[:info]).to eq("In order to begin, you need a connection with another person. Request a connection so that you can start splitting expenses.")
        end
      end

      context "but there is a connection request" do
        before do
          ConnectionRequest.create(from: other_user, to: current_user)
          get debts_path
        end

        it "redirects to connections#index" do
          expect(response).to redirect_to controller: :connections, action: :index
        end

        it "sets the flash" do
          expect(flash[:info]).to eq("In order to begin, you need a connection with another person. You already have someone who has requested to connect with you, so you can accept the request to start splitting expenses.")
        end
      end
    end

    context "when there are debts" do
      before do
        create_debt_on_day(ower: current_user, owed: other_user, date: Date.today)
      end

      context "and no connection requests" do
        it "returns a 200 OK" do
          get debts_path
          expect(response).to have_http_status(:ok)
        end
      end

      context "and there is a connection request" do
        before do
          ConnectionRequest.create(from: other_user, to: current_user)
          get debts_path
        end

        it "returns a 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "sets the flash" do
          expect(flash[:info]).to match("You have one or more connection requests.")
        end
      end
    end
  end

  describe "#update" do
    subject(:request) { patch debt_path(debt), params: parameters, as: :json }
    let(:parameters) do
      {
        id: debt.id,
        reconciled: true
      }
    end

    context "for a debt for which the current user is the ower" do
      let!(:debt) do
        create_debt_on_day(ower: current_user, owed: other_user, date: Date.today)
      end

      it "sets the ower_reconciled boolean attribute" do
        expect { request }.to change { debt.reload.ower_reconciled }
        expect(debt.ower_reconciled).to be true
      end

      it "does not change any other attributes" do
        expect { request }.not_to change { debt.reload.attributes.reject { |key, _| key.to_sym == :ower_reconciled } }
      end

      it "responds with the new value of the reconciled flag" do
        request
        expect(response.parsed_body["debt"]).to eq({ "reconciled" => debt.reload.ower_reconciled })
      end
    end

    context "for a debt for which the current user is the owed person" do
      let!(:debt) do
        create_debt_on_day(ower: other_user, owed: current_user, date: Date.today)
      end

      it "sets the owed_reconciled boolean attribute" do
        expect { request }.to change { debt.reload.owed_reconciled }
        expect(debt.owed_reconciled).to be true
      end

      it "does not change any other attributes" do
        expect { request }.not_to change { debt.reload.attributes.reject { |key, _| key.to_sym == :owed_reconciled } }
      end

      it "responds with the new value of the reconciled flag" do
        request
        expect(response.parsed_body["debt"]).to eq({ "reconciled" => debt.reload.owed_reconciled })
      end
    end

    context "for a debt that does not involve the current user" do
      let!(:debt) do
        create_debt_on_day(ower: other_user, owed: FactoryBot.create(:person), date: Date.today)
      end

      it "returns a 404" do
        request
        expect(response).to have_http_status(:missing)
      end

      it "does not change any attributes" do
        expect { request }.to_not change { debt.attributes }
      end
    end
  end
end

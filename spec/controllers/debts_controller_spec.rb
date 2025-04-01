require 'rails_helper'

RSpec.describe DebtsController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:other_user) { FactoryBot.create(:person) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    sign_in current_user
  end

  shared_examples "status ok" do
    it "returns a 200" do
      expect(subject).to have_http_status(:ok)
    end
  end

  describe "#index" do
    subject { get :index }

    shared_examples "redirects" do
      it "redirects to connections index" do
        expect(subject).to redirect_to controller: :connections, action: :index
      end
    end

    context "when there are no debts and no connections" do
      context "and no connection requests" do
        include_examples "redirects"

        it "sets the flash" do
          expect(subject.request.flash[:info]).to eq("In order to begin, you need a connection with another person. Request a connection so that you can start splitting expenses.")
        end
      end

      context "but there is a connection request" do
        before do
          ConnectionRequest.create(from: other_user, to: current_user)
        end

        include_examples "redirects"

        it "sets the flash" do
          expect(subject.request.flash[:info]).to eq("In order to begin, you need a connection with another person. You already have someone who has requested to connect with you, so you can accept the request to start splitting expenses.")
        end
      end
    end

    context "when there are debts" do
      before do
        create_debt_on_day(ower: current_user, owed: other_user, date: Date.today)
      end

      context "and no connection requests" do
        include_examples "status ok"
      end

      context "and there is a connection request" do
        before do
          ConnectionRequest.create(from: other_user, to: current_user)
        end

        include_examples "status ok"

        it "sets the flash" do
          expect(subject.request.flash[:info]).to match("You have one or more connection requests.")
        end
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: parameters, as: :json }
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

      include_examples "status ok"

      it "sets the ower_reconciled boolean attribute" do
        expect { subject }.to change { debt.reload.ower_reconciled }
        expect(debt.ower_reconciled).to be true
      end

      it "does not change any other attributes" do
        expect { subject }.not_to change { debt.reload.attributes.reject { |key, _| key.to_sym == :ower_reconciled } }
      end

      it "responds with the new value of the reconciled flag" do
        expect(subject.parsed_body['debt']).to eq({ "reconciled" => debt.reload.ower_reconciled })
      end
    end

    context "for a debt for which the current user is the owed person" do
      let!(:debt) do
        create_debt_on_day(ower: other_user, owed: current_user, date: Date.today)
      end

      include_examples "status ok"

      it "sets the owed_reconciled boolean attribute" do
        expect { subject }.to change { debt.reload.owed_reconciled }
        expect(debt.owed_reconciled).to be true
      end

      it "does not change any other attributes" do
        expect { subject }.not_to change { debt.reload.attributes.reject { |key, _| key.to_sym == :owed_reconciled } }
      end

      it "responds with the new value of the reconciled flag" do
        expect(subject.parsed_body['debt']).to eq({ "reconciled" => debt.reload.owed_reconciled })
      end
    end

    context "for a debt that does not involve the current user" do
      let!(:debt) do
        create_debt_on_day(ower: other_user, owed: FactoryBot.create(:person), date: Date.today)
      end

      it "returns a 404" do
        expect(subject).to have_http_status(:missing)
      end

      it "does not change any attributes" do
        expect { subject }.to_not change { debt.attributes }
      end
    end
  end
end

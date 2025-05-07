require 'rails_helper'

RSpec.describe "Connections", type: :request do
  let(:current_user) { FactoryBot.create(:person) }
  let(:other_user) { FactoryBot.create(:person) }
  let(:yet_another_user) { FactoryBot.create(:person) }

  before do
    sign_in current_user, scope: :person
  end

  shared_examples "redirect" do
    it "redirects to connections index" do
      request
      expect(response).to redirect_to controller: :connections, action: :index
    end
  end

  describe "#index" do
    it "returns a 200" do
      get connections_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create (accept a connection request)" do
    subject(:request) do
      post connections_path, params: { connection_request_id: connection_request.id }
    end

    context "when connection request is to current user" do
      let(:connection_request) do
        ConnectionRequest.create(from: other_user, to: current_user)
      end

      include_examples "redirect"

      it "creates connections" do
        expect { request }.to change(Connection, :count).by(2)
      end

      it "sets the flash" do
        request
        expect(flash[:info]).to eq("Connection request from #{connection_request.from.name} accepted.")
      end

      it "sends an email" do
        mail_delivery = double('connection_accepted_email')
        expect(mail_delivery).to receive(:deliver_now)
        expect(ConnectionMailer).to receive(:connection_accepted_email).
          with(other_user, current_user).and_return(mail_delivery)
        request
      end
    end

    context "when connection request is to someone else" do
      let(:connection_request) do
        ConnectionRequest.create(from: other_user, to: yet_another_user)
      end

      include_examples "redirect"

      it "doesn't create connections" do
        expect { request }.not_to change(Connection, :count)
      end
    end
  end
end

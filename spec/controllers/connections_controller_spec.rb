require 'rails_helper'

RSpec.describe ConnectionsController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:other_user) { FactoryBot.create(:person) }
  let(:yet_another_user) { FactoryBot.create(:person) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    sign_in current_user
  end

  describe "#index" do
    subject { get :index }

    it "returns a 200" do
      expect(subject).to have_http_status(:ok)
    end
  end

  describe "#create (accept a connection request)" do
    subject do
      post :create, params: { connection_request_id: connection_request.id }
    end

    context "connection request made to current user" do
      let(:connection_request) do
        ConnectionRequest.create(from: other_user, to: current_user)
      end

      it "creates connections" do
        expect { subject }.to change(Connection, :count).by(2)
      end

      it "sets the flash" do
        expect(subject.request.flash[:info]).to eq("Connection request from #{connection_request.from.name} accepted.")
      end

      it "sends an email" do
        mail_delivery = double('connection_accepted_email')
        expect(mail_delivery).to receive(:deliver_now)
        expect(ConnectionMailer).to receive(:connection_accepted_email).
          with(other_user, current_user).and_return(mail_delivery)
        subject
      end

      it "redirects to connections index" do
        expect(subject).to redirect_to controller: :connections, action: :index
      end
    end

    context "connection request made to someone else" do
      let(:connection_request) do
        ConnectionRequest.create(from: other_user, to: yet_another_user)
      end

      it "doesn't create connections" do
        expect { subject }.not_to change(Connection, :count)
      end

      it "redirects to connections index" do
        expect(subject).to redirect_to controller: :connections, action: :index
      end
    end
  end
end

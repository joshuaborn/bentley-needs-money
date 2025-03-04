require 'rails_helper'

RSpec.describe ConnectionRequestsController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:other_user) { FactoryBot.create(:person) }
  let(:yet_another_user) { FactoryBot.create(:person) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    sign_in current_user
    Connection.create(from: current_user, to: other_user)
    Connection.create(from: other_user, to: current_user)
  end

  shared_examples "redirect" do
    it "redirects to connections index" do
      expect(subject).to redirect_to controller: :connections, action: :index
    end
  end

  describe "#new" do
    subject { get :new }

    it "returns a 200" do
      expect(subject).to have_http_status(:ok)
    end
  end

  describe "#create" do
    subject do
      post :create, params: { connection_request: { to: { email: target_email } } }
    end

    context "when a connection already exists" do
      let(:target_email) { other_user.email }

      include_examples "redirect"

      it "sets the flash" do
        expect(subject.request.flash[:warning]).to match("You are already connected to")
      end

      it "doesn't create a connection request" do
        expect { subject }.not_to change(ConnectionRequest, :count)
      end
    end

    context "when email address is for someone with an account" do
      let(:target_email) { yet_another_user.email }

      include_examples "redirect"

      it "sets the flash" do
        expect(subject.request.flash[:info]).to match(/Connection with.*requested/)
      end

      it "creates a connection request" do
        expect { subject }.to change(ConnectionRequest, :count).by(1)
      end

      it "sends a connection request email" do
        mail_delivery = double('connection_request_email')
        expect(mail_delivery).to receive(:deliver_now)
        expect(ConnectionMailer).to receive(:connection_request_email).
          with(current_user, yet_another_user).and_return(mail_delivery)
        subject
      end
    end

    context "when email address is for someone with doesn't have an account" do
      let(:target_email) { Faker::Internet.unique.email }

      include_examples "redirect"

      it "sets the flash" do
        expect(subject.request.flash[:info]).to match("There is no account associated with")
      end

      it "creates a signup request" do
        expect { subject }.to change(SignupRequest, :count).by(1)
      end

      it "sends a signup request email" do
        mail_delivery = double('signup_request_email')
        expect(mail_delivery).to receive(:deliver_now)
        expect(ConnectionMailer).to receive(:signup_request_email).
          with(current_user, target_email).and_return(mail_delivery)
        subject
      end
    end
  end

  describe "#destroy (deny a connection request)" do
    subject { delete :destroy, params: { id: connection_request.id } }

    context "when connection request is to current user" do
      let!(:connection_request) do
        ConnectionRequest.create(from: other_user, to: current_user)
      end

      include_examples "redirect"

      it "sets the flash" do
        expect(subject.request.flash[:info]).to eq("Connection request from #{connection_request.from.name} denied.")
      end

      it "deletes a connection request" do
        expect { subject }.to change(ConnectionRequest, :count).by(-1)
      end
    end

    context "when connection request is to someone else" do
      let!(:connection_request) do
        ConnectionRequest.create(from: other_user, to: yet_another_user)
      end

      include_examples "redirect"

      it "doesn't delete a connection request" do
        expect { subject }.not_to change(ConnectionRequest, :count)
      end
    end
  end
end

require 'rails_helper'
require 'support/person_transfer_mapping.rb'
require 'support/build_expenses_for_tests.rb'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe TransfersController, type: :controller do
  let(:current_user) { FactoryBot.create(:person) }
  let(:connected_user) { FactoryBot.create(:person) }
  let(:unconnected_user) { FactoryBot.create(:person) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    sign_in current_user
  end

  describe "#index" do
    subject { get :index }

    shared_examples "redirects" do
      it "redirects to connections index" do
        expect(subject).to redirect_to controller: :connections, action: :index
      end
    end

    context "when there are no transfers and no connections" do
      context "and no connection requests" do
        include_examples "redirects"

        it "sets the flash" do
          expect(subject.request.flash[:info]).to eq("In order to begin, you need a connection with another person. Request a connection so that you can start splitting expenses.")
        end
      end

      context "but there is a connection request" do
        before do
          ConnectionRequest.create(from: connected_user, to: current_user)
        end

        include_examples "redirects"

        it "sets the flash" do
          expect(subject.request.flash[:info]).to eq("In order to begin, you need a connection with another person. You already have someone who has requested to connect with you, so you can accept the request to start splitting expenses.")
        end
      end
    end

    context "when there are transfers" do
      before do
        build_expenses_for_tests(current_user, connected_user, unconnected_user)
      end

      shared_examples "status ok" do
        it "returns a 200" do
          expect(subject).to have_http_status(:ok)
        end
      end

      context "and no connection requests" do
        include_examples "status ok"
      end

      context "and there is a connection request" do
        before do
          ConnectionRequest.create(from: connected_user, to: current_user)
        end

        include_examples "status ok"

        it "sets the flash" do
          expect(subject.request.flash[:info]).to match("You have one or more connection requests.")
        end
      end
    end
  end
end

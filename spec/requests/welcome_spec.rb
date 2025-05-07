require 'rails_helper'

RSpec.describe "Welcome", type: :request do
  describe "#index" do
    subject(:request) { get welcome_index_path }

    context "with a user signed in" do
      before do
        sign_in FactoryBot.create(:person), scope: :person
      end

      it "redirects to connections index" do
        request
        expect(response).to redirect_to controller: :debts, action: :index
      end
    end

    context "with no user signed in" do
      it "returns a 200" do
        request
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

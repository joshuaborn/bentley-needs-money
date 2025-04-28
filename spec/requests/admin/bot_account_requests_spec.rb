require 'rails_helper'

RSpec.describe "Admin::BotAccountRequests", type: :request do
  describe "GET /index" do
    context "when the current user is an administrator" do
      let(:administrator) { FactoryBot.create(:person, administrator: true) }

      it "returns a 200" do
        sign_in administrator, scope: :person
        get admin_bot_account_requests_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the current user is not an administrator" do
      let(:person) { FactoryBot.create(:person, administrator: nil) }

      it "redirects" do
        sign_in person, scope: :person
        get admin_bot_account_requests_path
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end

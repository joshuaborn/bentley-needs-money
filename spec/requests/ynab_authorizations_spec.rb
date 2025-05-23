require 'rails_helper'

RSpec.describe "YnabAuthorizations", type: :request do
  let(:current_user) { FactoryBot.create(:person) }

  before do
    sign_in current_user, scope: :person
  end

  describe "GET /new" do
    before do
      get new_ynab_authorization_path
    end

    it "returns a 200" do
      expect(response).to have_http_status(:ok)
    end

    it "includes a link to the YNAB OAuth website" do
      expect(response.body).to have_link("Connect to YNAB", href: /https:\/\/app\.ynab\.com\/oauth\/authorize/)
    end
  end

  describe "POST" do
    context "when an authorization code is provided" do
      let(:ynab_service) { instance_double(YnabService) }
      let(:code) { "8bc63e42-1105-11e8-b642-0ed5f89f718b" }

      before do
        allow(YnabService).to receive(:new).with(redirect_ynab_authorizations_url, current_user).and_return(ynab_service)
        allow(ynab_service).to receive(:request_access_tokens).with(code)
        get redirect_ynab_authorizations_url, params: { code: code }
      end

      it "redirects" do
        expect(response).to have_http_status(:redirect)
      end

      it "invokes a YnabService instance and calls #request_access_tokens" do
        expect(ynab_service).to have_received(:request_access_tokens).with(code)
      end
    end

    context "with no authorization code" do
      before do
        get redirect_ynab_authorizations_url, params: { code: nil }
      end

      it "redirects" do
        expect(response).to have_http_status(:redirect)
      end

      it "sets a flash message with an error" do
        expect(flash[:error]).to match(/Cannot authenticate with YNAB because no authorization code was provided./)
      end
    end
  end
end

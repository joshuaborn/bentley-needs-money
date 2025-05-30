require 'rails_helper'

RSpec.describe "YnabAuthorizations", type: :request do
  let(:current_user) { FactoryBot.create(:person) }

  before do
    sign_in current_user, scope: :person
  end

  describe "new" do
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

  describe "create" do
    let(:service) { double("YnabService") }
    let(:authorization_code) { "authorization code" }

    before do
      allow(YnabService).to receive(:new).and_return(service)
      allow(service).to receive(:request_access_tokens).and_return(service_result)
      get redirect_ynab_authorizations_path, params: { code: authorization_code }
    end

    context "on success" do
      let(:message) { "This is a success message." }
      let(:service_result) { ServiceResult.success(message) }

      it "redirects to home" do
        expect(response).to redirect_to root_path
      end

      it "sets the success message in the flash" do
        expect(flash[:notice]).to eq(message)
      end
    end

    context "on failure" do
      let(:message) { "This is a failure message." }
      let(:service_result) { ServiceResult.failure(message) }

      it "redirects back to the new path" do
        expect(response).to redirect_to action: 'new'
      end

      it "sets the failure message in the flash" do
        expect(flash[:error]).to eq(message)
      end
    end
  end
end

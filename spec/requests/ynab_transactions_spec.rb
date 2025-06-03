require 'rails_helper'

RSpec.describe "YnabAuthorizations", type: :request do
  let(:current_user) { FactoryBot.create(:person) }

  before do
    sign_in current_user, scope: :person
  end

  describe "#index" do
    context "when there are not access tokens for the user" do
      before do
        get ynab_transactions_path
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "includes a link to the YNAB OAuth website" do
        expect(response.body).to have_link("Connect to YNAB", href: /https:\/\/app\.ynab\.com\/oauth\/authorize/)
      end
    end

    context "when there are access tokens for the user" do
      let(:access_tokens) do
        {
          "access_token" => "0cd3d1c4-1107-11e8-b642-0ed5f89f718b",
          "token_type" => "bearer",
          "expires_in" => 7200,
          "refresh_token" => "13ae9632-1107-11e8-b642-0ed5f89f718b"
        }
      end
      let(:ynab_service) { instance_double(YnabService) }
      let(:ynab_transactions) { [] }
      let(:result) do
        ServiceResult.success('Success', ynab_transactions)
      end

      before do
        YnabService.new(current_user).send(:set_access_tokens, access_tokens)
        allow(YnabService).to receive(:new).with(current_user).and_return(ynab_service)
        allow(ynab_service).to receive(:get_access_token).and_return(access_tokens["access_token"])
        allow(ynab_service).to receive(:request_transactions).and_return(result)
        get ynab_transactions_path
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "calls request_transactions on the YNAB service" do
        expect(ynab_service).to have_received(:request_transactions)
      end

      it "does not include a link to the YNAB OAuth website" do
        expect(response.body).not_to have_link("Connect to YNAB", href: /https:\/\/app\.ynab\.com\/oauth\/authorize/)
      end
    end
  end
end

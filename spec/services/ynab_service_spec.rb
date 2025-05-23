require 'rails_helper'

RSpec.describe YnabService do
  include Rails.application.routes.url_helpers

  subject(:ynab_service) { YnabService.new(current_user) }
  let(:host) { 'localhost:3000' }
  let(:current_user) { FactoryBot.create(:person) }
  let(:access_token) { "0cd3d1c4-1107-11e8-b642-0ed5f89f718b" }
  let(:refresh_token) { "13ae9632-1107-11e8-b642-0ed5f89f718b" }

  before do
    Rails.application.routes.default_url_options[:host] = host
  end

  context "without a person object" do
    it "raises a YnabServiceError::ArgumentError" do
      expect { YnabService.new(nil) }.to raise_error(YnabService::ArgumentError)
    end
  end

  describe "#request_access_tokens" do
    let(:code) { "8bc63e42-1105-11e8-b642-0ed5f89f718b" }
    let(:expires_in) { 7200 }
    let(:redirect_uri) { redirect_ynab_authorizations_url }
    let(:request_content) do
      {
        "client_id" => Rails.application.credentials.ynab_client_id,
        "client_secret" => Rails.application.credentials.ynab_client_secret,
        "redirect_uri" => redirect_ynab_authorizations_url,
        "grant_type" => "authorization_code",
        "code" => code
      }
    end
    let(:response_content) do
      {
        "access_token" => access_token,
        "token_type" => "bearer",
        "expires_in" => expires_in,
        "refresh_token" => refresh_token
      }
    end

    context "without errors" do
      before do
        stub_request(:post, "https://app.ynab.com/oauth/token").with(
          headers: {
            'Content-Type' => 'application/json'
          },
          body: request_content.to_json
        ).to_return_json(body: response_content)
        ynab_service.request_access_tokens(redirect_uri, code)
      end

      it "encrypts and stores the authorization code in Redis" do
        expect(
          $lockbox.decrypt($redis.get("person:#{current_user.id}:ynab:authorization_code"))
        ).to eq(code)
      end

      it "encrypts and stores the access token in Redis" do
        expect(
          $lockbox.decrypt($redis.get("person:#{current_user.id}:ynab:access_token"))
        ).to eq(access_token)
      end

      it "gives the access token an expiration in Redis" do
        expect($redis.ttl("person:#{current_user.id}:ynab:access_token")).to eq(expires_in)
      end

      it "encrypts and sets the refresh token in Redis" do
        expect(
          $lockbox.decrypt($redis.get("person:#{current_user.id}:ynab:refresh_token"))
        ).to eq(refresh_token)
      end
    end

    context "without YNAB credentials for the application" do
      it "raises a YnabServiceError::InitializationError" do
        allow(Rails.application.credentials).to receive(:ynab_client_id) { nil }
        allow(Rails.application.credentials).to receive(:ynab_client_secret) { nil }
        expect { ynab_service.request_access_tokens(redirect_uri, code) }.to raise_error(YnabService::InitializationError)
      end
    end

    context "without a redirect_uri" do
      it "raises a YnabServiceError::ArgumentError" do
        expect { ynab_service.request_access_tokens(nil, code) }.to raise_error(YnabService::ArgumentError)
      end
    end

    context "without an authorization code " do
      it "raises a YnabServiceError::ArgumentError" do
        expect { ynab_service.request_access_tokens(current_user, nil) }.to raise_error(YnabService::ArgumentError)
      end
    end
  end
end

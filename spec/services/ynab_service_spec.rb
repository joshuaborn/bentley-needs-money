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

  describe "initialization" do
    context "with valid person" do
      it "creates a new instance" do
        expect { ynab_service }.not_to raise_error
      end

      it "sets up Faraday connection" do
        expect(ynab_service.instance_variable_get(:@conn)).to be_a(Faraday::Connection)
      end
    end

    context "without a person object" do
      it "raises a YnabServiceError::ArgumentError for a nil person" do
        expect { YnabService.new(nil) }.to raise_error(YnabService::ArgumentError, "There must be a currently logged-in person.")
      end

      it "raises a YnabServiceError::ArgumentError for a non-Person object" do
        expect { YnabService.new(FactoryBot.create(:debt)) }.to raise_error(YnabService::ArgumentError, "Parameter to YnabService must be a Person record.")
      end
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

    before do
      stub_request(:post, "https://app.ynab.com/oauth/token").with(
        headers: {
          'Content-Type' => 'application/json'
        },
        body: request_content.to_json
      ).to_return_json(body: response_content)
      ynab_service.request_access_tokens(redirect_uri, code)
    end

    context "with all expected parameters in response" do
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

    context "when there is no expires_in parameter in the response" do
      let(:response_content) do
        {
          "access_token" => access_token,
          "token_type" => "bearer",
          "refresh_token" => refresh_token
        }
      end

      it "stores the access token in Redis without expiration" do
        expect($redis.ttl("person:#{current_user.id}:ynab:access_token")).to eq(-1)
      end
    end

    context "when there is no refresh_token in the response" do
      let(:response_content) do
        {
          "access_token" => access_token,
          "token_type" => "bearer",
          "expires_in" => expires_in
        }
      end

      it "does not store a refresh token" do
        expect(
          $redis.get("person:#{current_user.id}:ynab:refresh_token")
        ).to be_nil
      end
    end

    context "without YNAB credentials for the application" do
      it "handles the YnabServiceError::InitializationError with a failure result" do
        allow(Rails.application.credentials).to receive(:ynab_client_id).and_return(nil)
        allow(Rails.application.credentials).to receive(:ynab_client_secret).and_return(nil)

        result = ynab_service.request_access_tokens(redirect_uri, code)
        expect(result).to be_failure
        expect(result.message).to eq("We're experiencing technical difficulties. Please try again later.")
      end
    end

    context "without a redirect_uri" do
      it "handles the YnabServiceError::ArgumentError when redirect_url is nil with a failure result" do
        result = ynab_service.request_access_tokens(nil, code)
        expect(result).to be_failure
        expect(result.message).to eq("Invalid authorization parameters. Please try connecting again.")
      end

      it "handles the YnabServiceError::ArgumentError when redirect_url is an empty string with a failure result" do
        result = ynab_service.request_access_tokens("", code)
        expect(result).to be_failure
        expect(result.message).to eq("Invalid authorization parameters. Please try connecting again.")
      end
    end

    context "without an authorization code " do
      it "handles the YnabServiceError::ArgumentError when code is nil with a failure result" do
        result = ynab_service.request_access_tokens(current_user, nil)
        expect(result).to be_failure
        expect(result.message).to eq("Invalid authorization parameters. Please try connecting again.")
      end

      it "handles the YnabServiceError::ArgumentError when code is an empty string with a failure result" do
        result = ynab_service.request_access_tokens(current_user, "")
        expect(result).to be_failure
        expect(result.message).to eq("Invalid authorization parameters. Please try connecting again.")
      end
    end

    context 'when API request fails' do
      it 'returns a failure result' do
        stub_request(:post, "https://app.ynab.com/oauth/token")
          .to_return(status: 401, body: { error: "invalid_client" }.to_json)

        result = ynab_service.request_access_tokens(redirect_uri, code)
        expect(result).to be_failure
        expect(result.message).to eq("Authorization failed. Please try connecting again.")
      end
    end
  end
end

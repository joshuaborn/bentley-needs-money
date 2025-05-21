require 'rails_helper'

RSpec.describe YnabService, type: :model do
  let(:current_user) { FactoryBot.create(:person) }
  subject(:ynab_service) { YnabService.new(current_user) }

  describe "#set_access_tokens" do
    let(:access_token) { "0cd3d1c4-1107-11e8-b642-0ed5f89f718b" }
    let(:expires_in) { 7200 }
    let(:refresh_token) { "13ae9632-1107-11e8-b642-0ed5f89f718b" }

    before do
      ynab_service.set_access_tokens(parameters)
    end

    context "with expiration" do
      let(:parameters) do
        {
          "access_token" => access_token,
          "token_type" => "bearer",
          "expires_in" => expires_in,
          "refresh_token" => refresh_token
        }
      end

      it "encrypts and sets the access token" do
        expect(
          $lockbox.decrypt($redis.get("person:#{current_user.id}:ynab:access_token"))
        ).to eq(access_token)
      end

      it "gives the access token an expiration" do
        expect($redis.ttl("person:#{current_user.id}:ynab:access_token")).to eq(expires_in)
      end

      it "encrypts and sets the refresh token" do
        expect(
          $lockbox.decrypt($redis.get("person:#{current_user.id}:ynab:refresh_token"))
        ).to eq(refresh_token)
      end
    end

    context "without expiration" do
      let(:parameters) do
        {
          "access_token" => access_token,
          "token_type" => "bearer"
        }
      end

      it "encrypts and sets the access token" do
        expect(
          $lockbox.decrypt($redis.get("person:#{current_user.id}:ynab:access_token"))
        ).to eq(access_token)
      end

      it "does not give the access token an expiration" do
        expect($redis.ttl("person:#{current_user.id}:ynab:access_token")).to eq(-1)
      end

      it "does not set a refresh token" do
        expect($redis.get("person:#{current_user.id}:ynab:refresh_token")).to be(nil)
      end
    end
  end
end

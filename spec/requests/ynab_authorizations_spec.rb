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
end

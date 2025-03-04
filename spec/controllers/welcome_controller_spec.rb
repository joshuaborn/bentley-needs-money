require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "user signed in" do
      before(:example) do
        @request.env["devise.mapping"] = Devise.mappings[:person]
        sign_in FactoryBot.create(:person)
      end

      it "redirects to connections index" do
        expect(subject).to redirect_to controller: :transfers, action: :index
      end
    end

    context "no user signed in" do
      it "returns a 200" do
        expect(subject).to have_http_status(:ok)
      end
    end
  end
end

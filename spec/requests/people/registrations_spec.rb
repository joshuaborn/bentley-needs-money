require 'rails_helper'

RSpec.describe "People::Registrations", type: :request do
  describe "POST /create" do
    let(:person) { FactoryBot.attributes_for(:person) }
    let(:params) {
      {
        person: {
          name: person[:name],
          email: person[:email],
          password: person[:password],
          password_confirmation: person[:password]
        }
      }
    }
    it "sends an account creation email" do
      mail_delivery = double('account_creation_email')
      expect(mail_delivery).to receive(:deliver_later)
      expect(AdminMailer).to receive(:account_creation_email).and_return(mail_delivery)
      post url_for(controller: 'people/registrations', action: 'create'), params: params
    end
  end
end

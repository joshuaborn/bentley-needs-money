require 'rails_helper'

RSpec.describe "People::Registrations", type: :request do
  describe "POST /create" do
    it "sends an account creation email" do
      mail_delivery = double('account_creation_email')
      expect(mail_delivery).to receive(:deliver_later)
      expect(AdminMailer).to receive(:account_creation_email).and_return(mail_delivery)
      post url_for(controller: 'people/registrations', action: 'create'), params: FactoryBot.attributes_for(:person)
    end
  end
end

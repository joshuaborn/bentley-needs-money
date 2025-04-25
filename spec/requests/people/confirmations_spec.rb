require 'rails_helper'

RSpec.describe "People::Confirmations", type: :request do
  describe "POST /create" do
    it "sends an account confirmation email" do
      mail_delivery = double('account_confirmation_email')
      expect(mail_delivery).to receive(:deliver_later)
      expect(AdminMailer).to receive(:account_confirmation_email).and_return(mail_delivery)
      get url_for(controller: 'people/confirmations', action: 'show')
    end
  end
end

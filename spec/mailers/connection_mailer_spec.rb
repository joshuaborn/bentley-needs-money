require 'rails_helper'

RSpec.describe ConnectionMailer, type: :mailer do
  describe ".signup_request_email" do
    subject(:email) { ConnectionMailer.signup_request_email(requestor, email_address) }
    let(:email_address) { Faker::Internet.email }
    let(:requestor) { FactoryBot.create(:person) }

    it do
      is_expected.to have_attributes(
        to: [ email_address ],
        from: [ "administrator@bentleyneeds.money" ],
        subject: "Request from #{requestor.name} to Connect"
      )
    end

    it "contains a link to the signup page" do
      expect(email.body.encoded).to match(
        new_person_registration_url(host: "localhost", port: 3000)
      )
    end
  end

  describe ".connection_request_email" do
    subject(:email) { ConnectionMailer.connection_request_email(requestor, requestee) }
    let(:requestee) { FactoryBot.create(:person) }
    let(:requestor) { FactoryBot.create(:person) }

    it do
      is_expected.to have_attributes(
        to: [ requestee.email ],
        from: [ "administrator@bentleyneeds.money" ],
        subject: "Request from #{requestor.name} to Connect"
      )
    end

    it "contains a link to the connections page" do
      expect(email.body.encoded).to match(
        connections_url(host: "localhost", port: 3000)
      )
    end
  end

  describe ".connection_accepted_email" do
    subject(:email) { ConnectionMailer.connection_accepted_email(requestor, requestee) }
    let(:requestee) { FactoryBot.create(:person) }
    let(:requestor) { FactoryBot.create(:person) }

    it do
      is_expected.to have_attributes(
        to: [ requestor.email ],
        from: [ "administrator@bentleyneeds.money" ],
        subject: "Connection with #{requestee.name} Accepted"
      )
    end

    it "contains a link to the index page" do
      expect(email.body.encoded).to match(
        debts_url(host: "localhost", port: 3000)
      )
    end
  end
end

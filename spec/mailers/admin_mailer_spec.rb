require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  let(:person) { FactoryBot.create(:person) }

  describe ".account_creation_email" do
    subject(:email) { AdminMailer.account_creation_email(person) }

    it "is sent to the administrator with information on the new account" do
      is_expected.to have_attributes(
        to: [ "administrator@bentleyneeds.money" ],
        from: [ "administrator@bentleyneeds.money" ],
        subject: "Account Created for #{person.name} <#{person.email}>"
      )
    end
  end

  describe ".account_confirmation_email" do
    subject(:email) { AdminMailer.account_confirmation_email(person) }

    it "is sent to the administrator with information on the new account" do
      is_expected.to have_attributes(
        to: [ "administrator@bentleyneeds.money" ],
        from: [ "administrator@bentleyneeds.money" ],
        subject: "Account Confirmed for #{person.name} <#{person.email}>"
      )
    end
  end
end

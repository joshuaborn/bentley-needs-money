class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("administrator@bentleyneeds.money", "Bentley Needs Money Administrator")
  layout "mailer"
end

class AdminMailer < ApplicationMailer
  def account_creation_email(person)
    @person = person
    mail(
      to: "administrator@bentleyneeds.money",
      subject: "Account Created for #{@person.name} <#{@person.email}>"
    )
  end

  def account_confirmation_email(person)
    @person = person
    mail(
      to: "administrator@bentleyneeds.money",
      subject: "Account Confirmed for #{@person.name} <#{@person.email}>"
    )
  end
end

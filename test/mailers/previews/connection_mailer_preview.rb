# Preview all emails at http://localhost:3000/rails/mailers/connection_mailer
class ConnectionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/connection_mailer/signup_request_email
  def signup_request_email
    ConnectionMailer.signup_request_email(Person.first, "joe.schmoe@example.com")
  end

  # Preview this email at http://localhost:3000/rails/mailers/connection_mailer/connection_request_email
  def connection_request_email
    ConnectionMailer.connection_request_email(Person.first, Person.last)
  end

  # Preview this email at http://localhost:3000/rails/mailers/connection_mailer/connection_accepted_email
  def connection_accepted_email
    ConnectionMailer.connection_accepted_email(Person.first, Person.last)
  end
end

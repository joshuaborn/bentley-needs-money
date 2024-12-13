# Preview all emails at http://localhost:3000/rails/mailers/connection_mailer
class ConnectionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/connection_mailer/signup_request_email
  def signup_request_email
    ConnectionMailer.with(from: Person.first, to: "joe.schmoe@example.com").signup_request_email
  end

  # Preview this email at http://localhost:3000/rails/mailers/connection_mailer/connection_request_email
  def connection_request_email
    ConnectionMailer.with(from: Person.first, to: Person.last).connection_request_email
  end
end

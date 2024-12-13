class ConnectionMailer < ApplicationMailer
  def signup_request_email(from, to)
    @from = from
    mail(
      to: to,
      subject: "Request from #{@from.name} to Connect"
    )
  end

  def connection_request_email(from, to)
    @from = from
    @to = to
    mail(
      to: @to.email,
      subject: "Request from #{@from.name} to Connect"
    )
  end

  def connection_accepted_email(from, to)
    @from = from
    @to = to
    mail(
      to: @from.email,
      subject: "Connection with #{to.name} Accepted"
    )
  end
end

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
end

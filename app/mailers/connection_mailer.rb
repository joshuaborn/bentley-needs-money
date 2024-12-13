class ConnectionMailer < ApplicationMailer
  def signup_request_email
    @from = params[:from]
    mail(
      to: params[:to],
      subject: "Request from #{@from.name} to Connect"
    )
  end

  def connection_request_email
    @from = params[:from]
    @to = params[:to]
    mail(
      to: @to.email,
      subject: "Request from #{@from.name} to Connect"
    )
  end
end

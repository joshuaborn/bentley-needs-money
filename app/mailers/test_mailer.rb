class TestMailer < ApplicationMailer
  def test_email
    mail(from: "joshua.born@gmail.com", to: "joshua.born@gmail.com", subject: "Test Email") do |format|
      format.text { render plain: "This is a test email." }
      format.html { render html: "<h1>This is a test email.</h1>".html_safe }
    end
  end
end

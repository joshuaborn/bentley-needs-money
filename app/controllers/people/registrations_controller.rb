class People::RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: [ :create ], scope: :person, honeypot: :username, on_spam: :log_spam_attempt

  def create
    super do |person|
      if person.persisted?
        AdminMailer.account_creation_email(person).deliver_later
      end
    end
  end

  protected
    def after_inactive_sign_up_path_for(resource_or_scope)
      new_person_session_path
    end

  private
    def log_spam_attempt
      BotAccountRequest.create(
        username: params["person"]["username"],
        name: params["person"]["name"],
        email: params["person"]["email"]
      )
      head :ok
    end
end

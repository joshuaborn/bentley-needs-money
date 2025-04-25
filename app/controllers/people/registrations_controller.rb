class People::RegistrationsController < Devise::RegistrationsController
  def create
    super do |person|
      AdminMailer.account_creation_email(person).deliver_later
    end
  end

  protected
    def after_inactive_sign_up_path_for(resource_or_scope)
      new_person_session_path
    end
end

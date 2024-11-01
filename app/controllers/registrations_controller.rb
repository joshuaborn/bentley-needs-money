class RegistrationsController < Devise::RegistrationsController
  protected
    def after_inactive_sign_up_path_for(resource_or_scope)
      new_person_session_path
    end
end

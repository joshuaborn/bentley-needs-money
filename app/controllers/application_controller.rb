class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_person!
  default_form_builder BulmaFormBuilder

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    end

  private
    def after_sign_out_path_for(resource_or_scope)
      new_person_session_path
    end
end

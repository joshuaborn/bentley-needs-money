class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_person!
  default_form_builder BulmaFormBuilder

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    end

    def render_debts_as_json
      decorator = DebtDecorator.new.for(current_person)
      render json: {
        "debts": Debt.for_person(current_person).map { |debt| decorator.decorate(debt).as_json }
      }
    end

  private
    def after_sign_out_path_for(resource_or_scope)
      flash.clear
      root_path
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || debts_path
    end
end

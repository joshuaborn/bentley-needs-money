class People::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do
      sign_in(resource) if resource.errors.empty?
    end
  end

  def after_confirmation_path_for(resource_name, resource)
    after_sign_in_path_for(resource)
  end
end

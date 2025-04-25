class People::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do
      sign_in(resource) if resource.errors.empty?
    end
  end

  def show
    super do |person|
      if person.persisted?
        AdminMailer.account_confirmation_email(person).deliver_later
      end
    end
  end

  def after_confirmation_path_for(resource_name, resource)
    after_sign_in_path_for(resource)
  end
end

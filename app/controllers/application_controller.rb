class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_person!
  default_form_builder BulmaFormBuilder

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    end

    def person_transfers_json_mapping(person)
      person.person_transfers.
        includes(:transfer, :person_transfers, :people).
        order(transfers: { date: :desc, created_at: :asc }).
        where([ "people.id <> ?", current_person ]).map do |person_transfer|
          {
            "date" => person_transfer.transfer.date,
            "dollarAmount" => person_transfer.dollar_amount,
            "dollarAmountPaid" => person_transfer.transfer.dollar_amount_paid,
            "id" => person_transfer.id,
            "inYnab" => person_transfer.in_ynab?,
            "memo" => person_transfer.transfer.memo,
            "otherPeople" => [
              {
                "cumulativeSum" => person_transfer.dollar_cumulative_sum,
                "date" => person_transfer.transfer.date,
                "dollarAmount" => person_transfer.other_person_transfer.dollar_amount,
                "id" => person_transfer.other_person.id,
                "name" => person_transfer.other_person.name
              }
           ],
            "payee" => person_transfer.transfer.payee,
            "transferId" => person_transfer.transfer_id,
            "type" => person_transfer.transfer.type
          }
        end
    end

  private
    def after_sign_out_path_for(resource_or_scope)
      flash.clear
      root_path
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || transfers_path
    end
end

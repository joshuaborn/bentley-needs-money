class PaybacksController < ApplicationController
  def create
    other_person = Person.find(params[:person][:id])
    if !current_person.is_connected_with?(other_person)
      render status: 404, json: {}
    else
      payback = Payback.new_from_parameters(
        current_person,
        other_person,
        create_payback_params()
      )
      if payback.save
        render json: {
          "person.transfers": person_transfers_json_mapping(current_person)
        }
      else
        render json: {
          "payback.errors": prefix_errors(payback.errors)
        }
      end
    end
  end

  def update
    begin
      payback = current_person.paybacks.find(params[:id])
      if payback.people.any? { |person| !person.is_connected_with?(current_person) }
        render status: 404, json: {}
      elsif payback.update(update_payback_params)
        render json: {
          "person.transfers": person_transfers_json_mapping(current_person)
        }
      else
        render json: {
          "payback.errors": prefix_errors(payback.errors)
        }
      end
    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {}
    end
  end

  def destroy
    begin
      payback = current_person.paybacks.find(params[:id])
      payback.destroy
      render json: {
        "person.transfers": person_transfers_json_mapping(current_person)
      }
    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {}
    end
  end

  private
    def prefix_errors(errors)
      {}.tap do |errors_hash|
        errors.to_hash.each do |key, val|
          errors_hash["payback." + key.to_s] = val
        end
      end
    end

    def create_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end

    def update_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end
end

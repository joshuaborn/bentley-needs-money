class SplitsController < ApplicationController
  class InvalidOwedId < StandardError; end
  def create
    begin
      other_person = current_person.connected_people.find(params[:person][:id])
      if params[:owed] == "self"
        split = Split.between_two_people(current_person, other_person, params_for_create())
      elsif params[:owed] == "other person"
        split = Split.between_two_people(other_person, current_person, params_for_create())
      else
        raise InvalidOwedId
      end
      if split.save
        render_debts_as_json
      else
        render json: {
          "errors": split.errors
        }
      end
    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {}
    rescue SplitsController::InvalidOwedId
      render status: 500, json: {}
    end
  end

  def update
    split = Split.find(params[:id])
    if split.people.any? { |person| !person.is_connected_with?(current_person) }
      render status: 404, json: {}
    elsif split.update(params_for_update)
      render_debts_as_json
    else
      render json: {
        "errors": split.errors
      }
    end
  end

  def destroy
    debts = Debt.for_person(current_person).where({ reasons: { id: params[:id], type: "Split" } })
    if debts.exists?
      debts.first.reason.destroy
      render_debts_as_json
    else
      render status: 404, json: {}
    end
  end

  private
    def params_for_create
      params.require(:split).permit(:dollar_amount, :date, :payee, :memo)
    end

    def params_for_update
      params.permit(
        :id,
        :date,
        :payee,
        :memo,
        :dollar_amount,
        debts_attributes: [ [ :id, :dollar_amount ] ]
      )
    end
end

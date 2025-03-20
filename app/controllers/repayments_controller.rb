class RepaymentsController < ApplicationController
  class InvalidRepayerId < StandardError; end
  def create
    begin
      other_person = current_person.connected_people.find(params[:person][:id])
      if params[:repayer] == "self"
        repayment = Repayment.new(
          current_person,
          other_person,
          params_for_create
        )
      elsif params[:repayer] == "other person"
        repayment = Repayment.new(
          other_person,
          current_person,
          params_for_create
        )
      else
        raise InvalidRepayerId
      end
      if repayment.save
        render_debts_as_json
      else
        render json: {
          "errors": repayment.errors
        }
      end
    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {}
    rescue RepaymentsController::InvalidRepayerId
      render status: 500, json: {}
    end
  end

  def update
    begin
      repayment = Repayment.find(params[:id])
      if repayment.people.any? { |person| !person.is_connected_with?(current_person) }
        render status: 404, json: {}
      elsif repayment.update(params_for_update)
        render_debts_as_json
      else
        render json: {
          "errors": repayment.errors
        }
      end
    rescue ActiveRecord::RecordNotFound
      render status: 404, json: {}
    end
  end

  def destroy
    debts = Debt.for_person(current_person).where({ reasons: { id: params[:id], type: "Repayment" } })
    if debts.exists?
      debts.first.reason.destroy
      render_debts_as_json
    else
      render status: 404, json: {}
    end
  end

  private
    def params_for_create
      params.require(:repayment).permit(:date, :dollar_amount)
    end

    def params_for_update
      params.permit(
        :id,
        :date,
        debts_attributes: [ [ :id, :dollar_amount ] ]
      )
    end
end

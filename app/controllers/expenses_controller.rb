class ExpensesController < ApplicationController
  def create
    other_person = current_person.connected_people.find(params[:person][:id])
    if params[:person_paid] == "current"
      @expense = Expense.split_between_two_people(current_person, other_person, create_expense_params())
    elsif params[:person_paid] == "other"
      @expense = Expense.split_between_two_people(other_person, current_person, create_expense_params())
    else
      raise StandardError.new("Unrecognized person_paid parameter")
    end
    if @expense.save
      render json: {
        "person.transfers": person_transfers_json_mapping(current_person)
      }
    else
      errors_hash = {}
      @expense.errors.to_hash.each do |key, val|
        errors_hash["expense." + key.to_s] = val
      end
      render json: {
        "expense.errors": errors_hash
      }
    end
  end

  private
    def create_expense_params
      params.require(:expense).permit(:dollar_amount_paid, :date, :payee, :memo)
    end

    def update_expense_params
      params.require(:expense).permit(
        :dollar_amount_paid, :date, :payee, :memo,
        person_transfers_attributes: [ :id, :dollar_amount, :in_ynab ]
      )
    end
end

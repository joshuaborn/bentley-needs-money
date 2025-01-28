class ExpensesController < ApplicationController
  def create
    other_person = current_person.connected_people.find(params[:person][:id])
    if params[:person_paid] == "current"
      expense = Expense.split_between_two_people(current_person, other_person, create_expense_params())
    elsif params[:person_paid] == "other"
      expense = Expense.split_between_two_people(other_person, current_person, create_expense_params())
    else
      raise StandardError.new("Unrecognized person_paid parameter")
    end
    if expense.save
      render json: {
        "person.transfers": person_transfers_json_mapping(current_person)
      }
    else
      render json: {
        "expense.errors": prefix_errors(expense.errors)
      }
    end
  end

  def update
    expense = Expense.find(params[:id])
    person_transfers_attributes = params[:other_person_transfers].map do |pt|
     {
       id: pt["id"],
       dollar_amount: pt["dollar_amount"]
     }
    end
    params.delete(:other_person_transfers)
    person_transfers_attributes.append(params[:my_person_transfer])
    params.delete(:my_person_transfer)
    params[:expense][:person_transfers_attributes] = person_transfers_attributes
    if expense.people.any? { |person| !person.is_connected_with?(current_person) }
      render status: 404, json: {}
    elsif expense.update(update_expense_params(params))
      render json: {
        "person.transfers": person_transfers_json_mapping(current_person)
      }
    else
      render json: {
        "expense.errors": prefix_errors(expense.errors)
      }
    end
  end

  def destroy
    expense = current_person.expenses.find(params[:id])
    expense.destroy
    render json: {
      "person.transfers": person_transfers_json_mapping(current_person)
    }
  end

  private
    def prefix_errors(errors)
      {}.tap do |errors_hash|
        errors.to_hash.each do |key, val|
          if key.to_s == "person_transfers"
            errors_hash["my_person_transfer.dollar_amount"] = val
            errors_hash["other_person_transfers.0.dollar_amount"] = val
          else
            errors_hash["expense." + key.to_s] = val
          end
        end
      end
    end

    def create_expense_params
      params.require(:expense).permit(:dollar_amount_paid, :date, :payee, :memo)
    end

    def update_expense_params(parameters)
      parameters.permit(
        expense: [
            :date,
            :dollar_amount_paid,
            :memo,
            :payee,
            person_transfers_attributes: [ [ :id, :dollar_amount, :in_ynab ] ]
        ]
      )[:expense]
    end
end

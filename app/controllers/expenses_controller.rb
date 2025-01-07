class ExpensesController < ApplicationController
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

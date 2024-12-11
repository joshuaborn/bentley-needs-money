class ExpensesController < ApplicationController
  def new
    @expense = Expense.new
    @people = current_person.connected_people
    render layout: false
  end

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
      flash[:info] = "Expense was successfully created."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      @people = current_person.connected_people
      render :new, status: 422, layout: false
    end
  end

  def edit
    @person_transfer = current_person.person_transfers.find(params[:id])
    @expense = @person_transfer.transfer
    render layout: false
  end

  def update
    @expense = current_person.expenses.find(params[:id])
    if @expense.people.any? { |person| !person.is_connected_with?(current_person) }
      render :edit, status: 404, layout: false
    elsif @expense.update(update_expense_params)
      flash[:info] = "Expense was successfully updated."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      render :edit, status: 422, layout: false
    end
  end

  def destroy
    current_person.expenses.find(params[:id]).destroy!
    flash[:info] = "Expense was successfully deleted."
    render turbo_stream: turbo_stream.action(:refresh, "")
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

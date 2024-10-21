class ExpensesController < ApplicationController
  def new
    @expense = Expense.new
    @people = Person.where.not(id: @current_user).all
    render layout: false
  end

  def create
    other_person = Person.find(params[:person][:id])
    if params[:person_paid] == "current"
      @expense = Expense.split_between_two_people(@current_user, other_person, create_expense_params())
    elsif params[:person_paid] == "other"
      @expense = Expense.split_between_two_people(other_person, @current_user, create_expense_params())
    else
      raise StandardError.new("Unrecognized person_paid parameter")
    end
    if @expense.save
      flash[:info] = "Transaction was successfully created."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      @people = Person.where.not(id: @current_user).all
      render :new, status: 422, layout: false
    end
  end

  def edit
    @person_transfer = @current_user.person_transfers.find(params[:id])
    @expense = @person_transfer.transfer
    render layout: false
  end

  def update
    @expense = @current_user.expenses.find(params[:id])
    if @expense.update(update_expense_params)
      flash[:info] = "Transaction was successfully updated."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      render :edit, status: 422, layout: false
    end
  end

  def destroy
    @current_user.expenses.find(params[:id]).destroy!
    flash[:info] = "Transaction was successfully deleted."
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

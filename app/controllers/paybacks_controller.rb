class PaybacksController < ApplicationController
  def new
    @payback = Payback.new
    @payback.date = Date.today
    @person_transfers = @current_user.get_amounts_owed
    render layout: false
  end

  def create
    other_person = Person.find(params[:person][:id])
    @payback = Payback.new_from_parameters(
      @current_user,
      other_person,
      create_payback_params()
    )
    if @payback.save!
      flash[:info] = "Payback was successfully created."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      @person_transfers = @current_user.get_amounts_owed
      render :new, status: 422, layout: false
    end
  end

  def edit
    @payback = @current_user.person_transfers.find(params[:id]).transfer
    @other_person = @payback.people.find { |person| person != @current_user }
    render layout: false
  end

  def update
    @payback = @current_user.paybacks.find(params[:id])
    if @payback.update(update_payback_params)
      flash[:info] = "Payback was successfully updated."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      render :edit, status: 422, layout: false
    end
  end

  def destroy
    @current_user.paybacks.find(params[:id]).destroy!
    flash[:info] = "Payback was successfully deleted."
    render turbo_stream: turbo_stream.action(:refresh, "")
  end

  private
    def create_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end

    def update_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end
end

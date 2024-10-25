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
    @person_transfers = @current_user.get_amounts_owed
    render layout: false
  end

  private
    def create_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end
end

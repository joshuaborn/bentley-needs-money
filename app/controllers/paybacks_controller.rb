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
      params[:payback][:date],
      @current_user,
      other_person,
      params[:payback][:dollar_amount_paid]
    )
    if @payback.save!
      flash[:info] = "Payback was successfully created."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      @person_transfers = @current_user.get_amounts_owed
      render :new, status: 422, layout: false
    end
  end
end

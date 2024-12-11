class PaybacksController < ApplicationController
  def new
    @payback = Payback.new
    @payback.date = Date.today
    @person_transfers = current_person.get_amounts_owed
    render layout: false
  end

  def create
    other_person = Person.find(params[:person][:id])
    if current_person.is_connected_with?(other_person)
      @payback = Payback.new_from_parameters(
        current_person,
        other_person,
        create_payback_params()
      )
      if @payback.save!
        flash[:info] = "Payback was successfully created."
        render turbo_stream: turbo_stream.action(:refresh, "")
      else
        @person_transfers = current_person.get_amounts_owed
        render :new, status: 422, layout: false
      end
    else
      @payback = Payback.new
      @payback.date = Date.today
      @person_transfers = current_person.get_amounts_owed
      render :new, status: 404, layout: false
    end
  end

  def edit
    @payback = current_person.person_transfers.find(params[:id]).transfer
    @other_person = @payback.people.find { |person| person != current_person }
    render layout: false
  end

  def update
    @payback = current_person.paybacks.find(params[:id])
    if @payback.people.any? { |person| !person.is_connected_with?(current_person) }
      @other_person = @payback.people.find { |person| person != current_person }
      render :edit, status: 404, layout: false
    elsif @payback.update(update_payback_params)
      flash[:info] = "Payback was successfully updated."
      render turbo_stream: turbo_stream.action(:refresh, "")
    else
      @other_person = @payback.people.find { |person| person != current_person }
      render :edit, status: 422, layout: false
    end
  end

  def destroy
    current_person.paybacks.find(params[:id]).destroy!
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

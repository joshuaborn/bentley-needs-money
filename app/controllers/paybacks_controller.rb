class PaybacksController < ApplicationController
  def new
    @payback = Payback.new
    @payback.date = Date.today
    @person_transfers = @current_user.get_amounts_owed
    render layout: false
  end
end

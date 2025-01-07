class PaybacksController < ApplicationController
  private
    def create_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end

    def update_payback_params
      params.require(:payback).permit(:dollar_amount_paid, :date)
    end
end

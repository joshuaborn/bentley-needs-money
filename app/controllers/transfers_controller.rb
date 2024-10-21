class TransfersController < ApplicationController
  layout "side_frame"

  def index
    @person_transfers = @current_user.person_transfers.includes(:transfer, :person_transfers, :people).order(transfers: { date: :desc })
  end
end

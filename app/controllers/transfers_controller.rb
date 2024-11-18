class TransfersController < ApplicationController
  layout "side_panel"

  def index
    @person_transfers = current_person.person_transfers.includes(:transfer, :person_transfers, :people).order(transfers: { date: :desc, created_at: :asc })
  end
end

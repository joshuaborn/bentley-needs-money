class TransfersController < ApplicationController
  layout "side_panel"

  def index
    @person_transfers = current_person.person_transfers.
      includes(:transfer, :person_transfers, :people).
      order(transfers: { date: :desc, created_at: :asc })
    if current_person.inbound_connection_requests.any?
      flash.now[:info] = "You have one or more connection requests. Navigate to the <a href='#{url_for connections_path}' target='_top'>Connections page</a> to approve or deny connection requests.".html_safe
    end
  end
end

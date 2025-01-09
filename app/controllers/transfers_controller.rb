class TransfersController < ApplicationController
  layout "navigable"
  def index
    if current_person.person_transfers.empty? and current_person.connections.empty?
      if current_person.inbound_connection_requests.any?
        flash[:info] = "In order to begin, you need a connection with another person. You already have someone who has requested to connect with you, so you can accept the request to start splitting expenses."
      else
        flash[:info] = "In order to begin, you need a connection with another person. Request a connection so that you can start splitting expenses."
      end
      redirect_to connections_path
    else
      @person_transfers = current_person.person_transfers.
        includes(:transfer, :person_transfers, :people).
        order(transfers: { date: :desc, created_at: :asc })
      if current_person.inbound_connection_requests.any?
        flash.now[:info] = "You have one or more connection requests. Navigate to the <a href='#{url_for connections_path}' target='_top'>Connections page</a> to approve or deny connection requests.".html_safe
      end
    end
  end
end

class ConnectionsController < ApplicationController
  def index
  end

  def create
    connection_request = ConnectionRequest.find(params[:connection_request_id])
    if connection_request.to == current_person
      Connection.create(from: connection_request.from, to: connection_request.to)
      Connection.create(from: connection_request.to, to: connection_request.from)
      ConnectionMailer.connection_accepted_email(connection_request.from, connection_request.to).deliver_now
      flash[:info] = "Connection request from #{connection_request.from.name} accepted."
      connection_request.destroy
    end
    redirect_to connections_path
  end
end

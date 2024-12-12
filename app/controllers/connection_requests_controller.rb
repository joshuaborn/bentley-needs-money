class ConnectionRequestsController < ApplicationController
  def destroy
    connection_request = ConnectionRequest.find(params[:id])
    if connection_request.to == current_person
      connection_request.destroy
      flash[:info] = "Connection request from #{connection_request.from.name} denied."
    end
    redirect_to connections_path
  end
end

class ConnectionRequestsController < ApplicationController
  def new
    @connection_request = ConnectionRequest.new
  end
  def destroy
    connection_request = ConnectionRequest.find(params[:id])
    if connection_request.to == current_person
      connection_request.destroy
      flash[:info] = "Connection request from #{connection_request.from.name} denied."
    end
    redirect_to connections_path
  end
  def create
    return_value = current_person.request_connection(params[:connection_request][:to][:email])
    if return_value.kind_of?(Connection)
      flash[:warning] = "You are already connected to #{return_value.to.name} (#{return_value.to.email})."
    elsif return_value.kind_of?(ConnectionRequest)
      flash[:info] = "Connection with #{return_value.to.name} (#{return_value.to.email}) requested."
    elsif return_value.kind_of?(SignupRequest)
      flash[:info] = "There is no account associated with the email address " + return_value.to + " in the system. An email was sent to this address requesting account creation."
    end
      redirect_to connections_path
  end
end

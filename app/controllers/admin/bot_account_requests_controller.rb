class Admin::BotAccountRequestsController < ApplicationController
  def index
    if current_person.administrator?
      @pagy, @requests = pagy(BotAccountRequest.order(created_at: :desc))
    else
      redirect_to root_path
    end
  end
end

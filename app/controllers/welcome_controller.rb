class WelcomeController < ApplicationController
  skip_before_action :authenticate_person!
  layout "base"

  def index
    redirect_to transfers_path if person_signed_in?
  end
end

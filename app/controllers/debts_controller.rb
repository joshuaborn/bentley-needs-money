class DebtsController < ApplicationController
  layout "navigable"
  def index
    debts = Debt.for_person(current_person)
    if debts.empty?
      if current_person.inbound_connection_requests.any?
        flash[:info] = "In order to begin, you need a connection with another person. You already have someone who has requested to connect with you, so you can accept the request to start splitting expenses."
      else
        flash[:info] = "In order to begin, you need a connection with another person. Request a connection so that you can start splitting expenses."
      end
      redirect_to connections_path
    else
      decorator = DebtDecorator.new.for(current_person)
      @debts = debts.map { |debt| decorator.decorate(debt).as_json }
      @connected_people = current_person.connected_people.select(:id, :name)
      if current_person.inbound_connection_requests.any?
        flash.now[:info] = "You have one or more connection requests. Navigate to the <a href='#{url_for connections_path}' target='_top'>Connections page</a> to approve or deny connection requests.".html_safe
      end
    end
  end

  def update
    debt = Debt.find(params[:id])
    if debt.ower == current_person
      debt.update_column(:ower_reconciled, params[:reconciled])
      render json: {
        debt: {
          reconciled: debt.reload.ower_reconciled
        }
      }
    elsif debt.owed == current_person
      debt.update_column(:owed_reconciled, params[:reconciled])
      render json: {
        debt: {
          reconciled: debt.reload.owed_reconciled
        }
      }
    else
      render status: 404, json: {}
    end
  end
end

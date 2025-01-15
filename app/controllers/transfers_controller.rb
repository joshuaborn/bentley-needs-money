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
        order(transfers: { date: :desc, created_at: :asc }).
        where([ "people.id <> ?", current_person ]).map do |person_transfer|
          {
            "date" => person_transfer.transfer.date,
            "dollarAmount" => person_transfer.dollar_amount,
            "dollarAmountPaid" => person_transfer.transfer.dollar_amount_paid,
            "id" => person_transfer.id,
            "inYnab" => person_transfer.in_ynab?,
            "memo" => person_transfer.transfer.memo,
            "otherPeople" => [
              {
                "cumulativeSum" => person_transfer.dollar_cumulative_sum,
                "date" => person_transfer.transfer.date,
                "dollarAmount" => person_transfer.other_person_transfer.dollar_amount,
                "id" => person_transfer.other_person.id,
                "name" => person_transfer.other_person.name
              }
           ],
            "payee" => person_transfer.transfer.payee,
            "transferId" => person_transfer.transfer_id,
            "type" => person_transfer.transfer.type
          }
        end
      @connected_people = current_person.connected_people.select(:id, :name)
      if current_person.inbound_connection_requests.any?
        flash.now[:info] = "You have one or more connection requests. Navigate to the <a href='#{url_for connections_path}' target='_top'>Connections page</a> to approve or deny connection requests.".html_safe
      end
    end
  end
end

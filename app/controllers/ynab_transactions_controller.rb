class YnabTransactionsController < ApplicationController
  def index
    ynab_service = YnabService.new(current_person)
    if ynab_service.get_access_token.nil?
      ynab_parameters = {
          client_id: Rails.application.credentials.ynab_client_id,
          redirect_uri: redirect_ynab_authorizations_url,
          response_type: "code"
      }.compact
      @ynab_oauth_url = "https://app.ynab.com/oauth/authorize?" + ynab_parameters.to_query
    else
      result = ynab_service.request_transactions
      render json: result.payload.to_json
    end
  end
end

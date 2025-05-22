class YnabAuthorizationsController < ApplicationController
  def new
    ynab_parameters = {
        client_id: Rails.application.credentials.ynab_client_id,
        redirect_uri: ynab_authorizations_url,
        response_type: "code"
    }.compact
    @path = "https://app.ynab.com/oauth/authorize?" + ynab_parameters.to_query
  end
end

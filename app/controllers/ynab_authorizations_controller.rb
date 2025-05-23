class YnabAuthorizationsController < ApplicationController
  def new
    ynab_parameters = {
        client_id: Rails.application.credentials.ynab_client_id,
        redirect_uri: redirect_ynab_authorizations_url,
        response_type: "code"
    }.compact
    @path = "https://app.ynab.com/oauth/authorize?" + ynab_parameters.to_query
  end

  def redirect
    if !params[:code].nil?
      ynab = YnabService.new(redirect_ynab_authorizations_url, current_person)
      ynab.request_access_tokens(params[:code])
    else
      flash[:error] = "Cannot authenticate with YNAB because no authorization code was provided."
    end
    redirect_to :root
  end
end

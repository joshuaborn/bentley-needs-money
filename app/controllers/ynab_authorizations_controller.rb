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
    ynab = YnabService.new(current_person)
    result = ynab.request_access_tokens(redirect_ynab_authorizations_url, params[:code])
    if result.success?
      flash[:notice] = result.message
      redirect_to root_path
    else
      flash[:error] = result.message
      redirect_to new_ynab_authorization_path
    end
  end
end

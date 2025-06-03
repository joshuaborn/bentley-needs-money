class YnabAuthorizationsController < ApplicationController
  def redirect
    ynab = YnabService.new(current_person)
    result = ynab.request_access_tokens(redirect_ynab_authorizations_url, params[:code])
    if result.success?
      flash[:notice] = result.message
    else
      flash[:error] = result.message
    end
    redirect_to ynab_transactions_path
  end
end

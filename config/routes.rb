Rails.application.routes.draw do
  get "welcome/index"
  devise_for :people, controllers: {
    registrations: "people/registrations",
    confirmations: "people/confirmations"
  }
  resources :connections, only: [ :index, :create ]
  resources :connection_requests, only: [ :new, :create, :destroy ]
  resources :debts, only: [ :index, :update ]
  resources :splits, only: [ :create, :update, :destroy ]
  resources :repayments, only: [ :create, :update, :destroy ]
  resources :people, except: [ :show ]
  namespace :admin do
    resources :people, only: [ :index ]
    resources :bot_account_requests, only: [ :index ]
  end
  resources :ynab_authorizations, only: [] do
    collection do
      get "redirect"
    end
  end
  resources :ynab_transactions, only: [ :index ]
  root "welcome#index"
end

Rails.application.routes.draw do
  get "welcome/index"
  devise_for :people, controllers: {
    registrations: "people/registrations",
    confirmations: "people/confirmations"
  }
  resources :connections, only: [ :index, :create ]
  resources :connection_requests, only: [ :new, :create, :destroy ]
  resources :transfers, only: [ :index ]
  resources :expenses, only: [ :create, :update, :destroy ]
  resources :paybacks, only: [ :create, :update, :destroy ]
  resources :people, except: [ :show ]
  root "welcome#index"
end

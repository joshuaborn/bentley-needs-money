Rails.application.routes.draw do
  get "welcome/index"
  devise_for :people, controllers: {
    registrations: "people/registrations",
    confirmations: "people/confirmations"
  }
  resources :transfers, only: [ :index ]
  resources :expenses, except: [ :index, :show ]
  resources :paybacks, except: [ :index, :show ]
  resources :people, except: [ :show ]
  root "welcome#index"
end

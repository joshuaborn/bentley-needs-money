Rails.application.routes.draw do
  devise_for :people
  resources :transfers, only: [ :index ]
  resources :expenses, except: [ :index, :show ]
  resources :paybacks, except: [ :index, :show ]
  resources :people, except: [ :show ]
  root "transfers#index"
end

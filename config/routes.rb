Rails.application.routes.draw do
  resources :rides, only: [:index]
end
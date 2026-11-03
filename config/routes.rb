Rails.application.routes.draw do
  devise_for :users
  root to: "prototypes#index"
  resources :prototypes, only: [:index, :new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
end

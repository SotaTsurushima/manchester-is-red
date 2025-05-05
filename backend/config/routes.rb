Rails.application.routes.draw do
  get "/matches", to: "matches#index"
  get "/transfers", to: "transfers#index"
  get '/injuries', to: 'injury_players#index'
  post 'upload', to: 'uploads#create'
  resources :players, only: [:index, :create, :show, :update, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end

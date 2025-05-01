Rails.application.routes.draw do
  get "/matches", to: "matches#index"

  get "up" => "rails/health#show", as: :rails_health_check
end

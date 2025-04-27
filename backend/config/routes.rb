Rails.application.routes.draw do
  # get 'manchester_united', to: 'manchester_united#index'
  get "up" => "rails/health#show", as: :rails_health_check
end

Rails.application.routes.draw do
  get "health", to: "health#index", as: :health_check
end

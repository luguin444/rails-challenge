Rails.application.routes.draw do
  get "health", to: "health#index", as: :health_check

  post 'products/upload', to: 'products#upload'
end

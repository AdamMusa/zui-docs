Rails.application.routes.draw do
  root "home#index"

  get "components", to: "catalog#index", as: :components
  get "components/:slug", to: "catalog#show", as: :component
  get "guides/:slug", to: "guides#show", as: :guide
  get "search", to: "search#index", defaults: { format: :json }, as: :search

  namespace :studio do
    resources :guides, only: %i[index edit update]
    root "guides#index"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end

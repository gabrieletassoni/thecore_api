require 'thecore'
require 'ransack'

Rails.application.routes.draw do
  # REST API (Stateless)
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :sessions, only: [:create]
      namespace :info do
        get :version
        get :token
      end
      resources :users, only: [:index, :create, :show, :update, :destroy] do
        match 'search' => 'users#search', via: [:get, :post], as: :search, on: :collection
      end
    end
  end
end

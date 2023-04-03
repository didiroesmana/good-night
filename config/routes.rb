Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      post '/login', to: 'sessions#create'

      get '/my_sleep_records', to: 'sleep_records#my_sleep_records'
      resources :sleep_records, only: [:create, :index]
      resources :following, only: [:create, :destroy]
    end
  end
end

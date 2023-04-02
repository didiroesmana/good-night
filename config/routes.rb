Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      post '/login', to: 'sessions#create'

      post '/following/:id', to: 'following#create'
      delete '/following/:id', to: 'following#destroy'
    end
  end
end

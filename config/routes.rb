Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    get '/auth/google/callback', to: 'sessions#create'
    get '/auth/failure', to: 'sessions#failure'

    get '/signin', to: redirect( path: '/auth/google' )
    get '/signout', to: 'sessions#destroy'

    get '/dashboard', to: 'users#show'

    resources :projects
    resources :notifications, only: [:index, :update, :destroy]
    get 'notifications/recent', to: 'notifications#recent'

    root 'landing#index'
end

Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    get '/auth/google/callback', to: 'sessions#create'
    get '/auth/failure', to: 'sessions#failure'

    get '/signin', to: redirect( path: '/auth/google' )
    get '/signout', to: 'sessions#destroy'

    get '/dashboard', to: 'users#show'

    scope :api do
        get '/projects/metadata', to: 'projects#get_metadata'
        resources :projects
    end
    get '/projects', to: redirect( path: '/dashboard' )

    # resources :notifications, only: [:index, :update, :destroy]
    # get 'notifications/recent', to: 'notifications#recent'

    # scope :api do
    #     resources :notifications, only: [:index, :update, :destroy]
    #     get 'notifications/recent', to: 'notifications#recent'
    # end

    root 'landing#index'
end

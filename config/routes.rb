Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    get '/auth/google/callback', to: 'sessions#create'
    get '/auth/failure', to: 'sessions#failure'

    get '/signin', to: redirect( path: '/auth/google' )
    get '/signout', to: 'sessions#destroy'

    root 'landing#index'
end

Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    get '/auth/google/callback', to: 'sessions#create'
    get '/auth/failure', to: 'sessions#failure'

    get '/signin', to: redirect( path: '/auth/google' )
    get '/signout', to: 'sessions#destroy'

    get '/dashboard', to: 'projects#index'
    get '/dashboard/project/:id', to: 'projects#index'
    # get '/api/projects', to: redirect( path: '/dashboard' )

    scope :api do
        get 'index.json', to: 'landing#fetch_json'
        get 'dashboard.json', to: 'projects#index'
        get '/projects/metadata.json', to: 'projects#get_metadata'
        resources :projects
    end

    root 'landing#index'
end

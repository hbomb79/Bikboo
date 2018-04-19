Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    get '/auth/google/callback', to: 'sessions#create'
    get '/auth/failure', to: 'sessions#failure'

    get '/signin', to: redirect( path: '/auth/google' )
    get '/signout', to: 'sessions#destroy'

    get '/dashboard', to: 'projects#index'
    get '/dashboard/project/:id', to: 'projects#index'
    get '/dashboard/create', to: 'projects#new'
    # get '/api/projects', to: redirect( path: '/dashboard' )

    scope :api do
        get 'index.json', to: 'landing#fetch_json'
        get 'dashboard.json', to: 'projects#index'
        get 'user.json', to: 'users#get_current_user'
        get '/dashboard/create.json', to: 'projects#new'
        get '/dashboard/project/:id', to: 'projects#show'
        get '/projects/metadata.json', to: 'projects#get_metadata'
        get '/projects/:id.json', to: 'projects#get_project_information'
        resources :projects
    end

    root 'landing#index'
end

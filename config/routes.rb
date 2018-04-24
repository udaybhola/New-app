require 'resque/server'

Rails.application.routes.draw do
  devise_for :admins

  get "/", to: 'high_voltage/pages#show', id: 'about'

  authenticate :admin do
    mount Resque::Server.new, at: "/resque"
  end

  namespace :admin do
    get "/", to: 'dashboard#index'
    get "/clear_cache", to: 'dashboard#clear_cache'
    get "/flagged_resources", to: 'dashboard#flagged_resources'
    post "/approve_resource", to: 'dashboard#approve_resource'
    post "/block_resource", to: 'dashboard#block_resource'
    post "/archive_resource", to: 'dashboard#archive_resource'
    post "/unarchive_resource", to: 'dashboard#unarchive_resource'

    resources :country_states do
      delete 'map', to: 'country_states#unlink_map', as: 'unlink_map'
      get 'map', to: 'country_states#link_map', as: 'link_map'
      post 'map', to: 'country_states#save_map_link', as: 'save_map_link'

      resources :constituencies do
        delete 'map', to: 'constituencies#unlink_map', as: 'unlink_map'
        get 'map', to: 'constituencies#link_map', as: 'link_map'
        post 'map', to: 'constituencies#save_map_link', as: 'save_map_link'
      end
    end

    resources :elections do
      resources :candidates do 
        member do 
          get 'link_page'
          post 'link'
        end
      end
      resources :candidatures
      resources :bulk_upload
    end

    resources :mobile_app_settings, only: [:index, :edit, :update]

    resources :polls
    resources :issues
    resources :parties
    resources :labels
    resources :leaders
    
    resources :religions
    resources :castes
    resources :professions
    resources :language_labels, only: [:index] do
      collection do
        post 'upload'
      end
    end
    resources :languages, only: [:index] do
      post 'make_available'
      post 'make_unavailable'
    end

    resources :users, only: [:index, :show] do 
      member do 
        post 'deactivate'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', skip: [:registrations]
      get '/master-data', to: 'home#master_data'
      get '/cloudinary-config', to: 'home#cloudinary_config'
      get '/dashboard-data', to: 'home#dashboard_data'
      resources :categories, only: [:index]
      namespace :posts do
        get '/categories', to: 'categories#count'
      end
      concern :top_parties do
        member do
          get 'top_parties'
          post 'parties_stats'
        end
      end
      concern :likeable do
        member do
          post 'like'
          post 'unlike'
        end
      end
      concern :searchable do
        collection do
          get 'search'
        end
      end
      concern :voteable do
        member do
          post 'vote'
        end
      end
      concern :manifestoable do
        member do
          get 'manifesto'
        end
      end
      resources :posts, only: [:index, :show, :create], concerns: [:likeable, :voteable] do
        member do
          get 'poll_stats'
          get 'comments'
          post 'flag'
        end
        collection do
          get 'mine'
          get 'national'
        end
        resources :comments, only: [:create], concerns: [:likeable] do
          member do
            post 'reply'
            get 'replies'
            post 'flag'
          end
        end
      end
      resources :candidates, only: [:show] do
        member do
          get 'candidatures'
          get 'posts'
        end
      end
      resources :candidatures, only: [:index], concerns: [:searchable, :voteable, :manifestoable] do
        member do
          get 'messages'
          post 'message'
          get 'commented_issues'
          post 'cancel_vote'
          post 'cancel_and_revote'
        end
        collection do
          get 'current_voted_candidate'
        end
      end
      resources :influencers, only: [:index, :show, :update], concerns: [:searchable] do
        member do
          get 'activity'
          get 'posts'
          get 'scorelog'
        end
      end
      scope :influencers, module: :influencers, as: :influencers do
        get 'influencer', action: :show
        patch 'influencer/update', action: :update
      end
      resources :parties, only: [:index, :show], concerns: [:manifestoable] do
        member do
          get 'party_leaders'
          get 'manifesto'
          post 'join'
        end
      end
      resources :constituencies, only: [], defaults: { format: 'json' }, concerns: [:top_parties] do
        collection do
          get 'latlng'
          get 'assembly'
          get 'parliament'
          get 'assembly_geojson'
          get 'parliament_geojson'
          get 'constituency_geojson'
        end
        member do
          get 'image'
        end
      end

      resources :country_states, only: [], defaults: { format: 'json' }, concerns: [:top_parties] do
        member do
          get 'geojson'
          get 'top_parties_constituency_wise'
        end
        collection do
          get 'top_parties'
          post 'parties_stats'
          get 'geojson_parliamentary'
          get 'popular_influencers'
          get 'popular_candidatures'
          get 'top_parties_constituency_wise'
        end
      end

      resources :candidate_nominations, only: [:create], defaults: { format: 'json' }

      resources :share_links, only: [], defaults: { format: 'json' } do
        collection do
          post 'post'
          post 'constituency'
          post 'candidature'
          post 'country_state'
          post 'influencer'
        end
      end

      resources :translations, only: [:index], defaults: { format: 'json' } do
        collection do
          get 'available_languages'
        end
      end
    end
  end

  scope module: 'web' do
    resources :constituencies, only: [:show] do
      get 'map'
      resources :polls, only: [:show]
      resources :issues, only: [:show]

      resources :candidates, only: [:show]
      resources :influencers, only: [:show]
    end

    resources :states, only: [:show] do
      resources :polls, only: [:show]
      resources :issues, only: [:show]
      resources :parties, only: [] do
        collection do
          get 'map'
        end
      end
      collection do
        get '/parties/map'
      end
    end

    resources :polls, only: [:show]
    resources :issues, only: [:show]
  end

  post '/login', to: 'api/v1/device_login#login'
  post '/logout', to: 'api/v1/device_login#logout'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

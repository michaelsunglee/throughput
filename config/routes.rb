Rails.application.routes.draw do
  resources :searches
  resources :artists, only: [:index]
  get 'find_artist', to: 'artists#find_artist'
  get 'get_artist_from_query', to: 'searches#get_artist', remote: true
  root to: 'artists#index'
end

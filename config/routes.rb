Rails.application.routes.draw do
  resources :searches
  resources :artists, only: [:index, :create, :new]
  root to: 'artists#new'
end

Rails.application.routes.draw do
  resources :searches, only: [:show, :new, :create]
  resources :artists, only: [:new, :create]
  root to: 'artists#new'
end

Rails.application.routes.draw do
  resources :searches
  root to: 'searches#new'
end

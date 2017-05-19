Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }
  root 'categories#index'

  resources :categories do
    post :search
  end

  resources :products, only: [:favorite, :stop_notifying] do
    get :favorite
    get :stop_notifying, on: :collection
  end
end

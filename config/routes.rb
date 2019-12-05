Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'
  resources :trips do
    member do
      patch :preferences
      get :details
      patch :save
      get :mistery
      patch :change_mistery
    end
    resources :steps, only: ['create', 'new']
  end
  resources :steps, only: ['index', 'show']
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  resources :subjects
  resources :areas
  resources :study_plans
  resources :schools
  resources :periods
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

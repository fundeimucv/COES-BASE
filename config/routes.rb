Rails.application.routes.draw do
  resources :period_types
  resources :academic_processes, :enroll_academic_processes, :academic_records, :periods, :profiles

  resources :courses do
    resources :sections
  end

  resources :banks do
    resources :payment_reports
  end
  
  resources :faculties do
    resources :schools do
      resources :admission_types, :grades, :study_plans
      resources :areas do
        resources :subjects
      end
    end
  end

  devise_for :users
  root to: "pages#home"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

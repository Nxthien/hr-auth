Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]
  as :user do
    get "users/edit" => "devise/registrations#edit", as: "edit_user_registration"
    put "users" => "devise/registrations#update", as: "user_registration"
  end

  authenticated :user, lambda {|u| u.admin?} do
    root "admin/users#index"
  end

  authenticated :user, lambda {|u| u.normal?} do
    root "clients#index"
  end

  unauthenticated :user do
    devise_scope :user do
      root "devise/sessions#new"
    end
  end

  get "/auth/hr_system/authorize" => "auth#authorize"
  post "/auth/hr_system/access_token" => "auth#access_token"
  get "/me" => "auth#me"

  resources :clients, only: [:index, :create, :show, :destroy]
  resources :users, only: [:show, :update]

  namespace :admin do
    root "users#index"
    resources :users
  end
end

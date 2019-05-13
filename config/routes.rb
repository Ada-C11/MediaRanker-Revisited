Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "works#root", as: "root"
  #get "/login", to: "users#login_form", as: "login"
  #post "/login", to: "users#login"
  #post "/logout", to: "users#logout", as: "logout"

  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"
  get "/users/current", to: "users#current", as: "current_user"
  resources :users, only: [:index, :show]
  get "/auth/github", as: "github_login"

  get "/auth/:provider/callback", to: "users#create", as: "auth_callback"
  delete "/logout", to: "users#destroy", as: "logout"
end

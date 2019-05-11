Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "works#root"
  
  resources :works
  
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#create", as: "auth_callback"
  get "/users/current", to: "users#current", as: "current_user"

  post "/works/:id/upvote", to: "works#upvote", as: "upvote"

  delete "/logout", to: "users#destroy", as: "logout"
  
  resources :users, only: [:index, :show]
end

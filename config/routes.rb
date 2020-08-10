Rails.application.routes.draw do
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/failure'
  root 'releases#view'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  #Omni Auth for Github
  get "/auth/:provider/callback" => "sessions#create"
  get "/signout" => "sessions#destroy", :as => :signout
  get "/signup" => redirect("/auth/github"), :as => :signup

  #Sidekiq Dashboard
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  mount Sidekiq::Web => '/sidekiq'
end

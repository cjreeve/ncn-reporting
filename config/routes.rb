Rails.application.routes.draw do

  resources :regions
  get 'regions/:id/group_options' => 'regions#group_options'

  resources :labels

  get 'site/notifications'
  get 'site/notification_emails'
  get 'site/updates_count'

  get 'updates' => 'updates#show', as: :updates

  resources :administrative_areas

  get '/page/:slug' => 'pages#view', as: :view_page
  get '/welcome' => 'pages#main', as: :main_page

  resources :pages

  get '/controls' => 'pages#controls', as: :controls

  get 'users' => 'users#index', as: 'users_index'
  get '/users/:id/user_info' => 'users#user_info'
  get 'user/route_areas' => 'users#route_areas', as: :user_route_areas

  resources :comments

  namespace :admin do
    resources :users
  end

  devise_for :users, controllers: { registrations: "users/registrations" }
  get '/users/:id' => 'users#show', as: :user


  resources :problems

  resources :categories do
    get :problems
  end

  resources :groups

  resources :images

  put 'images/:id/rotate/:direction' => 'images#rotate', as: :rotate_image

  resources :routes

  resources :segments do
    member do
      get 'check'
    end
  end


  authenticated :user do
    root to: 'issues#index'
  end
  get '/' => 'site#welcome'

  get '/site/mini_search' => 'site#mini_search', as: :mini_search

  resources :issues do
    member do
      put 'progress'
      put 'toggle_twins'
    end
  end
  get '/issue/:issue_number' => 'issues#show', as: :issue_number
  patch '/issue/:issue_number' => 'issues#update'
  get '/issue/:issue_number/follow' => 'issues#follow', as: :follow_issue
  get '/issue/:issue_number/unfollow' => 'issues#unfollow', as: :unfollow_issue


  get '/search' => 'issues#search', as: :issues_search

  get '*everything' => 'pages#main'
end

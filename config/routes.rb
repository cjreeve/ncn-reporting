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


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

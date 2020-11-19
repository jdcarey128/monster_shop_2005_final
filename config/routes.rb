Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/', to: 'welcome#index', as: 'root'
  resource :login, only: [:create], controller: 'sessions', as: 'login'
  resource :logout, only: [:destroy], controller: 'sessions'

  # root 'welcome#index'
  # the login new is non restful
  get "/login", to: "sessions#new"
  # post "/login", to: "sessions#create"
  # delete "/logout", to: "sessions#destroy"

  get '/admin', to: 'admin/dashboard#index', as: 'admin_root'
  get '/admin/users', to: 'admin/users#index', as: 'admin_users'
  get '/admin/users/:id', to: 'admin/users#show', as: 'admin_user'
  patch '/admin/orders/:id', to: 'admin/orders#update', as: 'admin_order'
  get '/admin/merchants', to: 'admin/merchants#index', as: 'admin_merchants'
  get '/admin/merchants/:id', to: 'admin/merchants#show', as: 'admin_merchant'
  patch '/admin/merchants/:id', to: 'admin/merchants#update'
  get '/admin/merchants/:merchant_id/items', to: 'admin/merchants/items#index', as: 'admin_merchants_items'
  get '/admin/merchants/:merchant_id/items/new', to: 'admin/merchants/items#new', as: 'new_admin_merchants_item'
  get '/admin/merchants/:merchant_id/items/:id/edit', to: 'admin/merchants/items#edit', as: 'edit_admin_merchants_item'
  post '/admin/merchants/:merchant_id/items', to: 'admin/merchants/items#create'
  patch '/admin/merchants/:merchant_id/items/:id', to: 'admin/merchants/items#update', as: 'admin_merchants_item'
  delete '/admin/merchants/:merchant_id/items/:id', to: 'admin/merchants/items#destroy'
  # namespace :admin do
    # root "dashboard#index"
    # resources :users, only: [:index, :show]
    # resources :orders, only: [:update]
    # resources :merchants, only: [:index, :show, :update]
    # resources :merchants, only: [:update]
    # namespace :merchants do
    #   scope '/:merchant_id/' do
    #     resources :items, except: [:show]
    #   end
    # end
  # end

  get '/merchant', to: 'merchant/dashboard#index', as: 'merchant_root'
  get '/merchant/items', to: 'merchant/items#index', as: 'merchant_items'
  post '/merchant/items', to: 'merchant/items#create'
  get '/merchant/items/new', to: 'merchant/items#new', as: 'new_merchant_item'
  get '/merchant/items/:id/edit', to: 'merchant/items#edit', as: 'edit_merchant_item'
  patch '/merchant/items/:id', to: 'merchant/items#update', as: 'merchant_item'
  delete '/merchant/items/:id', to: 'merchant/items#destroy'
  post '/merchant/discounts', to: 'merchant/discounts#create', as: 'merchant_discounts'
  get '/merchant/discounts/new', to: 'merchant/discounts#new', as: 'new_merchant_discount'
  get '/merchant/discounts/:id/edit', to: 'merchant/discounts#edit', as: 'edit_merchant_discount'
  patch '/merchant/discounts/:id', to: 'merchant/discounts#update', as: 'merchant_discount'
  delete '/merchant/discounts/:id', to: 'merchant/discounts#destroy'
  # get '/merchant/orders/:order_id', to: 'merchant/orders#show'
  # patch '/merchant/orders/:order_id', to: 'merchant/orders#update'

  namespace :merchant do
    # root 'dashboard#index'
    # resources :items, except: [:show]
    # resources :discounts, except: [:index, :show]

    resources :orders, only: [:show, :update], param: :order_id
    # get '/orders/:order_id', to: "orders#show"
    # patch '/orders/:order_id', to: "orders#update"
  end

  get '/merchants', to: 'merchants#index', as: 'merchants'
  get '/merchants/new', to: 'merchants#new', as: 'new_merchant'
  post '/merchants', to: 'merchants#create'
  get '/merchants/:id', to: 'merchants#show', as: 'merchant'
  get '/merchants/:id/edit', to: 'merchants#edit', as: 'edit_merchant'
  patch '/merchants/:id', to: 'merchants#update'
  # resources :merchants, except: [:delete]

  scope '/merchants/:merchant_id/' do
    resources :items, only: [:index], as: 'merchant_show_items'
  end
  # get "/merchants/:merchant_id/items", to: 'items#index'


  get '/items', to: 'items#index', as: 'items'
  get '/items/:id', to: 'items#show', as: 'item'
  # resources :items, only: [:index, :show]

  scope '/items/:item_id' do
    resources :reviews, only: [:new, :create]
  end
  # get "/items/:item_id/reviews/new", to: "reviews#new"
  # post "/items/:item_id/reviews", to: "reviews#create"

  get '/reviews/:id/edit', to: 'reviews#edit', as: 'edit_review'
  patch '/reviews/:id', to: 'reviews#update', as: 'review'
  # resources :reviews, only: [:edit, :update]

  resources :reviews, only: [:destroy]
  # delete "/reviews/:id", to: "reviews#destroy"

  #below is nonrestful
  post "/cart/:item_id", to: "cart#create"
  patch "/cart/:item_id", to: "cart#update"
  get "/cart", to: "cart#show"
  delete "/cart", to: "cart#destroy"
  delete "/cart/:item_id", to: "cart#destroy"


  namespace :profile do
    resources :orders, only: [:index]
    resources :orders, only: [:show], as: 'order_show'
    resources :orders, only: [:update], as: 'order_cancel'
  end
  # get '/profile/orders', to: 'profile/orders#index'
  # get '/profile/orders/:id', to: 'profile/orders#show', as: 'profile_order_show'
  # patch '/profile/orders/:id', to: 'profile/orders#update', as: 'profile_order_cancel'

  # namespace :profile do
  #   get "/orders", to: "orders#index"
  #   get "/orders/:id", to: "orders#show", as: "order_show"
  #   patch "/orders/:id", to: "orders#update", as: "order_cancel"
  # end


  resources :orders, only: [:new, :create, :show]
  # get "/orders/new", to: "orders#new"
  # post "/orders", to: "orders#create"
  # get "/orders/:id", to: "orders#show"


  resource :profile, controller: 'users', only: [:show, :update]
  resources :users, only: [:create]
  #below is non restful
  get "/register", to: "users#new"
  # post "/users", to: "users#create"
  # get "/profile", to: "users#show"
  #messed up the helper path so keeping the same
  get "/profile/edit", to: "users#edit"
  # patch "/profile", to: "users#update"
end

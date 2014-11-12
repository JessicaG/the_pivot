Rails.application.routes.draw do
  root 'welcome#index'

  get 'cart/edit'
  patch 'cart/add_item/:id', to: 'cart#add_item', as: 'cart_add_item'
  patch 'cart/remove_item/:id', to: 'cart#remove_item', as: 'cart_remove_item'
  patch 'cart/update_quantity/:id', to: 'cart#update_quantity', as: 'cart_update_quantity'
  delete 'cart/destroy'

  namespace :super_admin do
    get '', to: 'dashboard#index'
    # resources :items, except: [:index]
    resources :categories
    resources :vendors
    resources :users

    # resources :orders, only: [:index, :edit, :destroy]
    # patch '/order/status/:id/:status', to: 'orders#status', as: 'order_status'
    # patch '/orders/remove_item/:id/:item_id', to: 'orders#remove_item', as: 'order_remove_item'
    # patch '/orders/update_quantity/:id/:item_id', to: 'orders#update_quantity', as: 'order_update_quantity'
    # patch '/orders/updated_at/:id/:updated_at', to: 'orders#updated_at', as: 'updated_at'
    # get   '/orders/:status', to: 'orders#custom_show', as: 'order_custom_show'
  end

  namespace :vendor_admin do
    get '', to: 'dashboard#index'
    resources :items, except: [:index]
    # resources :categories
    resources :users
    resources :orders, only: [:index, :edit, :destroy]
    patch '/order/status/:id/:status', to: 'orders#status', as: 'order_status'
    patch '/orders/remove_item/:id/:item_id', to: 'orders#remove_item', as: 'order_remove_item'
    patch '/orders/update_quantity/:id/:item_id', to: 'orders#update_quantity', as: 'order_update_quantity'
    patch '/orders/updated_at/:id/:updated_at', to: 'orders#updated_at', as: 'updated_at'
    get   '/orders/:status', to: 'orders#custom_show', as: 'order_custom_show'
  end

  resources :charges
  resources :vendors
  resources :events
  resources :items, only: [:index, :show]
  resources :users, except: [:index, :show]
  get '/users/orders', to: 'users#show_orders', as: 'user_orders'
  resources :categories#, only: [:show]
  resources :cart_items, only: [:create]

  post 'orders/new', to: 'orders#store_lat_long'
  resources :orders, except: [:update, :edit, :destroy]
  # get 'orders/exchange', to: 'orders#exchange' <-- if separate order conf. page


  get 'items/:item_id/review', to: 'reviews#new', as: 'new_review'
  post 'items/:item_id/review', to: 'reviews#create', as: 'reviews'
  get 'items/:item_id/review/:id', to: 'reviews#edit', as: 'edit_review'
  patch 'items/:item_id/review/:id', to: 'reviews#update', as: 'review_update'
  get 'items/search', to: 'items#search', as: 'search_results'
  #resources :reviews, only: [:update]

  get '/about' => 'welcome#about'
  get '/code' => 'welcome#code'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  match '/contacts',     to: 'contacts#new',             via: 'get'
  resources "contacts", only: [:new, :create]

  get ':slug', to: 'vendors#show'

  scope ':slug' do
    get '/', to: 'vendors#show'
    resources :items, only: [:show], as: "vendor_item"
  end

end

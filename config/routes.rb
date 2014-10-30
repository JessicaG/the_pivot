Rails.application.routes.draw do
  root 'welcome#index'

  get 'cart/edit'
  patch 'cart/add_item/:id', to: 'cart#add_item', as: 'cart_add_item'
  patch 'cart/remove_item/:id', to: 'cart#remove_item', as: 'cart_remove_item'
  patch 'cart/update_quantity/:id', to: 'cart#update_quantity', as: 'cart_update_quantity'
  delete 'cart/destroy'

  # /my_tap_shoes/items/6
  #namespace ':store_slug' do
  #  resources :items
  #end
  #get ':store_slug/items', to: 'items#index'
  #get ':store_slug/items/:id', to: 'items#show'

  namespace :admin do
    get '', to: 'dashboard#index'
    resources :items, except: [:index]
    resources :categories
    resources :users
    resources :orders, only: [:index, :edit, :destroy]
    patch '/order/status/:id/:status', to: 'orders#status', as: 'order_status'
    patch '/orders/remove_item/:id/:item_id', to: 'orders#remove_item', as: 'order_remove_item'
    patch '/orders/update_quantity/:id/:item_id', to: 'orders#update_quantity', as: 'order_update_quantity'
    patch '/orders/updated_at/:id/:updated_at', to: 'orders#updated_at', as: 'updated_at'
    get   '/orders/:status', to: 'orders#custom_show', as: 'order_custom_show'
  end

  resources :vendors, only: [:index, :show]
  resources :events
  resources :items, only: [:index, :show]
  resources :users, except: [:index, :show]
  get '/users/orders', to: 'users#show_orders', as: 'user_orders'
  resources :categories#, only: [:show]
  resources :cart_items, only: [:create]
  resources :orders, except: [:update, :edit, :destroy]

  get 'items/:item_id/review', to: 'reviews#new', as: 'new_review'
  post 'items/:item_id/review', to: 'reviews#create', as: 'reviews'
  get 'items/:item_id/review/:id', to: 'reviews#edit', as: 'edit_review'
  patch 'items/:item_id/review/:id', to: 'reviews#update', as: 'review_update'
  #resources :reviews, only: [:update]

  get '/menu', to: 'pdf#menu', as: 'menu'

  get '/about' => 'welcome#about'
  get '/code' => 'welcome#code'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  match '/contacts',     to: 'contacts#new',             via: 'get'
  resources "contacts", only: [:new, :create]
end

Rails.application.routes.draw do
  post 'tees/upload_designs', to: 'tees#design_upload_callback'

  get 'admin', to: 'admin#admin'
  post 'admin', to: 'admin#admin'
  post 'admin/tracking', to: 'admin#upload_tracking'
  post 'admin/add_inventory', to: 'admin#add_inventory'

  post 'progress-job' => 'tees#increment_publish'

  get 'orders', to: 'orders#order_export'
  post 'orders', to: 'orders#process_order_export'

  get 'library', to: 'gallery#gallery'

  get 'account', to: 'account#add_payment_info'
  post 'account', to: 'account#add_payment_info'
  post 'account/delete_or_update', to: 'account#delete_or_update_customer'
  post 'account/update', to: 'account#update'

  resources :tees do
  	post 'review', on: :new
  	get 'review', on: :new
  	post 'publish', on: :new
  end

  get 'tees/new/publish', to: 'home#index'
  get 'tees/new/view_tee', to: 'tees#view_tee'

  post 'custom_webhooks/orders_create', to: 'custom_webhooks#orders_create'
  post 'custom_webhooks/orders_cancel', to: 'custom_webhooks#orders_cancel'
  get 'activatecharge', to: 'home#activatecharge'

  root :to => 'home#index'
  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

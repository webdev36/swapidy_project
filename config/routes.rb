Swapidy::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users, :controllers => {:sessions => "sessions", 
                                      :registrations => "registrations", 
                                      :omniauth_callbacks => "users/omniauth_callbacks",
                                      :passwords =>"passwords"} do
    match "/users/sign_out" => "sessions#destroy"
    match "/users/redeem" => "registrations#redeem"
    match "/sent_resetpass" => "passwords#sent_resetpass"
  end

  #match 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'

  match "/for_sell" => "home#index", :method => :get, :show => "for_sell"
  match "/for_buy" => "home#index", :method => :get, :show => "for_buy"
  match "/about" => "home#static_page", :method => :get, :content => "about", :page_title => "About Us"
  match "/faq_general" => "home#static_page", :method => :get, :content => "faq_general", :page_title => "FAQ"
  match "/faq_buying" => "home#static_page", :method => :get, :content => "faq_buying", :page_title => "FAQ"
  match "/faq_selling" => "home#static_page", :method => :get, :content => "faq_selling", :page_title => "FAQ"
  match "/how_it_works" => "home#static_page", :method => :get, :content => "how_it_works", :page_title => "How it Works"
  match "/jobs" => "home#static_page", :method => :get, :content => "jobs", :page_title => "Jobs"
  match "/team" => "home#static_page", :method => :get, :content => "team", :page_title => "Our Team" 
  match "/terms" => "home#static_page", :method => :get, :content => "terms", :page_title => "Terms of Service"
  match "/privacy" => "home#static_page", :method => :get, :content => "privacy", :page_title => "Privacy Policy"
  match "/s4" => "home#static_page", :method => :get, :content => "s4", :page_title => "Pre-order S4"
  match "/howitworks" => "home#static_page", :method => :get, :content => "howitworks", :page_title => "How it Works"

  match "/testimonials" => "home#static_page", :method => :get, :content => "testimonials", :page_title => "Testimonials"

  match "/send_contact" => "home#contact_us", :method => :post
  match "/contact_us" => "home#static_page", :method => :get, :content => "contact_us", :page_title => "Contact Us"

  match "/error_not_found" => "home#static_page", :method => :get, :content => "/error_pages/404"
  
  match "/location/vote" => "location#vote", :method => :post
  match "/location/:location" => "location#change", :method => :get
  
  resources :products
  match "/csv_import/:fn" => "products#csv_import"
  #match "/payments/new" => "payments#new", :method => :post
  #match "/payments/confirm" => "payments#confirm", :method => :post
  #match "/payments/edit_card" => "payments#edit_card", :method => :post
  #resources :payments do 
  #  post :create, :on => :member
  #  post :show, :on => :member
  #end
  
  match "/orders/email_info" => "orders#email_info", :method => :post
  match "/orders/payment_info" => "orders#payment_info", :method => :post
  match "/orders/shipping_info" => "orders#shipping_info", :method => :post
  match "/orders/confirm" => "orders#confirm", :method => :post
  match "/orders/create" => "orders#create", :method => :post
  match "/orders/complete" => "orders#complete", :method => :get
  match "/orders/change_email" => "orders#change_email", :method => :post
  match "/orders/change_paypal_email" => "orders#change_paypal_email", :method => :post
  match "/orders/change_certified_name" => "orders#change_certified_name", :method => :post

  match "/orders/change_shipping_info" => "orders#change_shipping_info", :method => :post
  match "/orders/reload_payment_order_info" => "orders#reload_payment_order_info", :method => :post

  resources :orders
  
  match "/transactions" => "home#transactions", :method => :get
  
  match "/notifications/refresh" => "notifications#refresh", :method => :put
  match "/notifications/:id/hide" => "notifications#hide", :method => :put
  resources :notifications

  match "/free_moneys/confirm" => "free_moneys#confirm", :method => :get
  match "/free_moneys/confirm_complete" => "free_moneys#confirm_complete", :method => :get
  match "/free_moneys/invalid_token" => "free_moneys#invalid_token", :method => :get
  match "/free_moneys/create" => "free_moneys#create", :method => :post
  #resources :free_moneys
  
  match "/redeem" => "redeem#index", :method => :get
  resources :redeem
  match "/home/disconect_fb" => "home#disconect_fb"
  match "/home/swap_product" => "home#swap_product"
  match "/home/del_product" => "home#del_product"
  match "/home/clear_checkout_item" => "home#clear_checkout_item"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

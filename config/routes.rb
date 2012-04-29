Whichbus::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'signup' }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :route do
    get 'favorite', :on => :member
  end
  resources :stop
  resources :trip

  root :to => "journey#new"
  
  match "journey" => "journey#show"
  match "options" => "journey#options"
  match "options_sms" => "journey#options_sms"
  match "s/:id" => "stop#show"
  match "search" => "stop#search"
  match "stop/:id/schedule" => "stop#schedule"
  match "route/:id/trips" => "route#trips"
  match "deals/:city" => "deal#find_by_city"
  match '/stats/get-by-distance/:latitude/:longitude/:distance/crime' => 'stat#find_crime_by_lat_long' , 
        :constraints => { :latitude => /[+-]?\d+\.\d+/ , :longitude  => /[+-]?\d+\.\d+/ },
        :defaults => { :format => 'json' }

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

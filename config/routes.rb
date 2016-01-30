Throneofthestars::Application.routes.draw do

  match '' => 'home#index', :as => :root
  match 'empire' => 'empire#index', :as => :empire
  match 'church' => 'church#index', :as => :church
  match 'announcements' => 'empire#announcements', :as => :announcements
  match 'login' => 'player_sessions#new', :as => :login
  match 'logout' => 'player_sessions#destroy', :as => :logout
  match 'password_reset' => 'password_resets#new', :as => :password_reset
  match 'password_reset/:id' => 'password_resets#edit', :as => :edit_password
  match 'confirm/:id' => 'players#confirm', :as => :confirm
  match 'House/:name' => 'noble_houses#show'
  match 'Planet/:name' => 'worlds#show'
  match 'Planet/:world/:name' => 'regions#show'
  match 'Item/:name' => 'items#show'
  match 'BuildingType/:name' => 'building_types#show'
  match 'ShipType/:name' => 'starship_types#show'
  match 'Character/:guid' => 'characters#show'
  match 'Starship/:guid' => 'starships#show'
  match 'Army/:guid' => 'armies#show'
  match 'Army/:guid/units/:id' => 'units#show'
  match 'Army/:guid/units/:id/edit' => 'units#edit'
  match 'Estate/:guid' => 'estates#show'
  match 'Character/:guid/promote' => 'characters#promote'
  match 'json/world_regions/:id' => 'json#world_regions'
  match 'json/region_estates/:id' => 'json#region_estates'
  match 'json/house_characters/:id' => 'json#house_characters'
  match 'json/single_females/:id' => 'json#single_females'
  match 'json/single_males/:id' => 'json#single_males'
  match 'json/army_units/:id' => 'json#army_units'
  match 'messages/preview' => 'messages#preview'
  match 'Message/:guid' => 'messages#show'
  match 'unsubscribe/:guid' => 'players#unsubscribe'
  match 'orders/:id/up' => 'orders#up'
  match 'orders/:id/down' => 'orders#down'
  match 'orders/:id/cancel' => 'orders#destroy'
  match 'admin' => 'admin#index'
  match 'admin/players' => 'admin#players'
  match 'admin/spawner' => 'admin#spawner'
  match 'admin/reported' => 'admin#reported'
  match 'admin/newsletter' => 'admin#newsletter'

  resources :starship_configurations
  resources :starship_configuration_items
  resources :units
  resources :armies
  resources :starships
  resources :starship_types
  resources :buildings
  resources :estates
  resources :characters
  resources :orders
  resources :messages
  resources :noble_houses
  resources :regions
  resources :items
  resources :worlds
  resources :building_types
  resources :player_sessions
  resources :players
  resources :image_files

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

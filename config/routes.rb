Rails.application.routes.draw do
  
  # Deviseはカスタマイズ可能。元々あるコントローラーを継承した子供のコントローラーを優先する
  devise_for :users, :controllers => {
    :registrations => 'users/registrations', #デフォルトのregistrationsコントローラを継承し'users/registrations'コントローラを使用
    :sessions => 'users/sessions', #デフォルトのsessionsコントローラを継承し'users/sessions'コントローラを使用
    :passwords => 'users/passwords', #デフォルトのpasswordsコントローラを継承し'users/passwords'コントローラを使用
    :confirmations => 'users/confirmations', #デフォルトのconfirmationsコントローラを継承し'users/confirmations'コントローラを使用
    :unlocks => 'users/unlocks', #デフォルトのunlocksコントローラを継承し'users/unlocks'コントローラを使用
  }

  devise_scope :user do
    # root :to => "users/sessions#new" #rootをusers/sessionsコントローラのnewアクション(ログイン画面)に設定
    root :to => "web#index"  #root_path	 GET	/	web#index (root(TOP画面)を web#indexに設定)
    get "signup", :to => "users/registrations#new" #signup...URL(アクセスする時)
    get "verify", :to => "users/registrations#verify" #アカウント作成後、メールの送信完了を知らせる画面にリダイレクトされるよう画面のルーティングを設定
    get "login", :to => "users/sessions#new"
    delete "logout", :to => "users/sessions#destroy"
  end
  
  
  devise_for :admins, :controllers => {
    :sessions => 'admins/sessions'  #デフォルトのsessionsコントローラを継承し'admins/sessions'コントローラを使用
  }
  
  devise_scope :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'dashboard/login', to: 'admins/sessions#new'  #  GET/ URL: dashboard/login で admins/sessionsコントローラのnewアクションを実行
    post 'dashboard/login', to: 'admins/sessions#create'
    delete 'dashboard/logout', to: 'admins/sessions#destroy'
  end
  
  namespace :dashboard do
    resources :categories, except: [:new] #ダッシュボードのカテゴリ管理 (newアクションを省く)
      # dashboard_categories_path	 GET 	/dashboard/categories  dashboard/categories#index
      #                            POST	/dashboard/categories  dashboard/categories#create
      # edit_dashboard_category_path	GET	/dashboard/categories/:id/edit	dashboard/categories#edit
      # dashboard_category_path	GET 	/dashboard/categories/:id   dashboard/categories#show
      #                         PUT	 /dashboard/categories/:id   dashboard/categories#update
      #                         DELETE	/dashboard/categories/:id   dashboard/categories#destroy
    resources :products, except: [:show] #ダッシュボードの商品管理 (showアクションを省く)
  end
  
  
  #users = mypage
  resource :users, only: [:edit, :update] do
    collection do
      get "cart", :to => "shopping_carts#index"  #cart_users_path 	GET	 /users/cart  shopping_carts#index
      post "cart", :to => "shopping_carts#create"   #cart_create_users_path	POST	/users/cart/create  shopping_carts#create
      delete "cart", :to => "shopping_carts#destroy"  #cart_users_path 	DELETE	/users/cart 	shopping_carts#destroy
      get "mypage", :to => "users#mypage"   #mypage_users  GET  /users/mypage  users#mypage
      get "mypage/edit", :to => "users#edit"   #mypage_edit_users  GET  /users/mypage/edit  users#edit
      get "mypage/address/edit", :to => "users#edit_address"   #mypage_address_edit_users  GET  /users/mypage/address/edit  users#edit_address
      put "mypage", :to => "users#update"   #mypage_address_edit_users  PUT  /users/mypage  users#update
      get "mypage/edit_password", :to => "users#edit_password"   #mypage_edit_password_users_path	 GET	/users/mypage/edit_password   users#edit_password
      put "mypage/password", :to => "users#update_password"     #mypage_password_users_path 	PUT	 /users/mypage/password   users#update_password
      get "mypage/favorite", :to => "users#favorite"   #mypage_favorite_users_path 	GET	 /users/mypage/favorite  users#favorite
    end
  end
  
  # アクションを追加する場合resourcesブロック内に member又はcollection を記述する
  # member :idをパラメータで渡したい場合
  # collection :全てのデータを対象としたアクションの場合(idをパラメータで渡さなくて良い場合)
  
  
  
  resources :products do
    resources :reviews, only: [:create]  #product_reviews  POST  /products/:product_id/reviews   reviews#create
    # post '/products/:product_id/reviews' => 'reviews#create'  でもOK
    
    member do
      get :favorite   #favorite_product  GET  /products/:id/favorite  products#favorite
    end
  end
  

end

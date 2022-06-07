Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :registrations => 'users/registrations', #デフォルトで作られてるregistrationsコントローラを継承して'users/registrations'コントローラを使ってね！
    :sessions => 'users/sessions', #デフォルトで作られてるsessionsコントローラを継承して'users/sessions'コントローラを使ってね！
    :passwords => 'users/passwords', #デフォルトで作られてるpasswordsコントローラを継承して'users/passwords'コントローラを使ってね！
    :confirmations => 'users/confirmations', #デフォルトで作られてるconfirmationsコントローラを継承して'users/confirmations'コントローラを使ってね！
    :unlocks => 'users/unlocks', #デフォルトで作られてるunlocksコントローラを継承して'users/unlocks'コントローラを使ってね！
  }
  # Deviseはカスタマイズしたら子供のコントローラを優先する
  
  devise_scope :user do
    # root :to => "users/sessions#new" #rootをusers/sessionsコントローラのnewアクション(ログイン画面)に設定
    root :to => "web#index"  #root_path	GET	/	web#index (root(TOP画面)を web#indexに設定)
    get "signup", :to => "users/registrations#new" #signup...URLにつける名前(アクセスする時)
    get "verify", :to => "users/registrations#verify" #アカウント作成後、メールの送信完了を知らせる画面にリダイレクトされるよう画面のルーティングを設定
    get "login", :to => "users/sessions#new"
    delete "logout", :to => "users/sessions#destroy"
  end
  
  
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
  
  
  # post '/products/:product_id/reviews' => 'reviews#create'
  
  resources :products do
    resources :reviews, only: [:create]
    
      #⬆︎︎ product_reviews  POST  /products/:product_id/reviews  reviews#create
    member do
      get :favorite
    end
      #⬆︎ favorite_product GET  /products/:id/favorite  products#favorite
  end
  

end

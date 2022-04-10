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
    root :to => "users/sessions#new" #rootをusers/sessionsコントローラのnewアクション(ログイン画面)に設定
    get "signup", :to => "users/registrations#new" #signup...URLにつける名前(アクセスする時)
    get "verify", :to => "users/registrations#verify" #アカウント作成後、メールの送信完了を知らせる画面にリダイレクトされるよう画面のルーティングを設定
    get "login", :to => "users/sessions#new"
    delete "logout", :to => "users/sessions#destroy"
  end
  
  
  resource :users, only: [:edit, :update] do
    collection do
      get "mypage", :to => "users#mypage"   #mypage_users  GET  /users/mypage  users#mypage
      get "mypage/edit", :to => "users#edit"   #mypage_edit_users  GET  /users/mypage/edit  users#edit
      get "mypage/address/edit", :to => "users#edit_address"   #mypage_address_edit_users  GET  /users/mypage/address/edit  users#edit_address
      put "mypage", :to => "users#update"   #mypage_address_edit_users  PUT  /users/mypage  users#update
    end
  end
  
  # アクションを追加する場合resourcesブロック内に member又はcollection を記述する
  # member :idをパラメータで渡したい場合
  # collection :全てのデータを対象としたアクションの場合(idをパラメータで渡さなくて良い場合)
  
  resources :products do
    resources :reviews, only: [:create]
      #⬆︎︎ product_reviews  POST  /products/:product_id/reviews  reviews#create
    member do
      get :favorite
    end
      #⬆︎ favorite_product GET  /products/:id/favorite  products#favorite
  end
  

end

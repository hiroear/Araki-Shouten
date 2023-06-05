Rails.application.routes.draw do
  
  # Deviseはカスタマイズ可能。元々あるコントローラーを継承した子供のコントローラーを優先する
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',   #デフォルトのregistrationsコントローラを継承し'users/registrations'コントローラを使用
    :sessions => 'users/sessions',
    :passwords => 'users/passwords',
    :confirmations => 'users/confirmations',
    :unlocks => 'users/unlocks',
  }

  devise_scope :user do
    root :to => "web#index"                            #root_path	 GET	/	web#index (root(TOP画面)を web#indexに設定)
    get "signup", :to => "users/registrations#new"     #signup...URL(アクセスする時)
    get "verify", :to => "users/registrations#verify"  #アカウント作成後、メールの送信完了を知らせる画面にリダイレクトされるよう画面のルーティングを設定
    get "login", :to => "users/sessions#new"
    delete "logout", :to => "users/sessions#destroy"
  end
  
  
  devise_for :admins, :controllers => {
    :sessions => 'admins/sessions'
  }
  
  devise_scope :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'dashboard/login', to: 'admins/sessions#new'
    post 'dashboard/login', to: 'admins/sessions#create'
    delete 'dashboard/logout', to: 'admins/sessions#destroy'
  end
  
  namespace :dashboard do                            # controllers/dashboard/
    resources :categories, except: [:new]            #ダッシュボード/カテゴリ管理 (newアクション省く)
    resources :products, except: [:show] do                        #/商品管理/商品一覧
      collection do                                                       #  /CSV一括登録
        get "import/csv", :to => "products#import"                 # GET 	/dashboard/products/import/csv
        post "import/csv", :to => "products#import_csv"            # POST	 /dashboard/products/import/csv
        get "import/csv_download", :to => "products#download_csv"  # GET	 /dashboard/products/import/csv_download
      end
    end
    resources :major_categories, except: [:new]    #ダッシュボード/親カテゴリ管理
    resources :users, only: [:index, :destroy]     #ダッシュボード/顧客管理(index/destroyアクションのみ)
    resources :orders, only: [:index, :show]       #ダッシュボード/受注一覧 & 詳細
  end
  
  
  #users = mypage
  resources :users, only: [] do  # collectionを書く為 resourcesで囲ったが resourcesで生成される7つのルーティングは必要ない為 only: [] とした(URLをusers/〜にする為)
    collection do
      get "cart", :to => "shopping_carts#index"
      post "cart", :to => "shopping_carts#create"
      delete "cart", :to => "shopping_carts#destroy"
      delete "cart/:id", :to => "shopping_carts#delete_item", as: 'cart_delete'
      get "mypage", :to => "users#mypage"
      get "mypage/edit", :to => "users#edit"
      get "mypage/address/edit", :to => "users#edit_address"
      put "mypage", :to => "users#update"
      get "mypage/edit_password", :to => "users#edit_password"
      get "mypage/password", :to => "users#update_password"
      put "mypage/password", :to => "users#update_password"
      get "mypage/favorite", :to => "users#favorite"
      delete "mypage/delete", :to => "users#destroy"
      get "mypage/cart_history", :to => "users#cart_history_index", :as => "mypage_cart_histories"
      get "mypage/cart_history/:num", :to => "users#cart_history_show", :as => "mypage_cart_history"
      get "mypage/register_card", :to => "users#register_card"
      post "mypage/token", :to => "users#token"
    end
  end
  
  # アクションを追加する場合resourcesブロック内に member又はcollection を記述
  # member :idをパラメータで渡したい場合
  # collection :全てのデータを対象としたアクションの場合(idをパラメータで渡さなくて良い場合)
  
  
  
  resources :products, only: [:index, :show, :favorite]  do
    resources :reviews, only: [:create]
    
    member do
      get :favorite   #favorite_product  GET  /products/:id/favorite  products#favorite
    end
  end
  

end

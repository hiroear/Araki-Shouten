Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :registrations => 'users/registrations', #デフォルトで作られてるregistrationsコントローラを継承して'users/registrations'コントローラを使ってね！
    :sessions => 'users/sessions', #デフォルトで作られてるsessionsコントローラを継承して'users/sessions'コントローラを使ってね！
    :passwords => 'users/passwords', #デフォルトで作られてるpasswordsコントローラを継承して'users/passwords'コントローラを使ってね！
    :confirmations => 'users/confirmations', #デフォルトで作られてるconfirmationsコントローラを継承して'users/confirmations'コントローラを使ってね！
    :unlocks => 'users/unlocks', #デフォルトで作られてるunlocksコントローラを継承して'users/unlocks'コントローラを使ってね！
  }
  # カスタマイズしたら子供のコントローラを優先する
  
  devise_scope :user do
    root :to => "users/sessions#new" #rootをusers/sessionsコントローラのnewアクション(ログイン画面)に設定
    get "signup", :to => "users/registrations#new" #signup...URLにつける名前(アクセスする)
    get "verify", :to => "users/registrations#verify" #アカウント作成後、メールの送信完了を知らせる画面にリダイレクトされるよう画面のルーティングを設定
    get "login", :to => "users/sessions#new"
    delete "logout", :to => "users/sessions#destroy"
  end
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

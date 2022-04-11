class UsersController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!
  # ⬆︎deviseで使えるようになったメソッド。before_action :authenticate_user!と記述することで、ログイン済みのユーザーのみアクセスを許可
  
  
  # 会員情報の編集画面へ
  # mypage_edit_users_path	GET	 /users/mypage/edit  	users#edit
  def edit
  end


  # 会員情報編集・更新
  # mypage_users_path	PUT 	/users/mypage	  users#update
  def update
    @user.update_without_password(user_params)
    # update_without_passwordは deviseをインストールし使えるようになった、パスワードなしでパスワード以外の値を変更できるメソッド
    redirect_to mypage_users_url
  end


  # マイページ画面へ
  # mypage_users_path	 GET	 /users/mypage	 users#mypage
  def mypage
  end
  
  
  # お届け先変更画面へ
  # mypage_address_edit_users_path	GET	 /users/mypage/address/edit 	users#edit_address
  def edit_address
  end
  
  
  # パスワード編集・更新
  # mypage_password_users_path	 PUT 	/users/mypage/password   users#update_password
  def update_password
    if password_set?  ︎#[:password]と[:password_confirmation]がフォームで送られてきたら
      @user.update_password(user_params) 
      flash[:notice] = "パスワードは正しく更新されました。"
      redirect_to root_url
    else              ︎#[:password]と[:password_confirmation]が存在しなければ
      @user.errors.add(:password, "パスワードに不備があります。")
      render "edit_password"
    end
  end
  
  
  # パスワード編集画面へ
  # mypage_edit_password_users_path	 GET	 /users/mypage/edit_password   users#edit_password
  def edit_password
  end
  
  
  # mypage_favorite_users_path 	GET	 /users/mypage/favorite  users#favorite
  def favorite
    @favorites = @user.likees(Product)
    # likeesメソッド :socializationをインストールしたことで使えるようになったメソッド
    # likees(Product) :ログインユーザーがお気に入りに追加したすべての商品のデータを取得
  end
  
  
  
  private
    def set_user
      @user = current_user
      # current_userメソッドを使い、ユーザー自身の情報を@userに代入
    end
    
  
    def user_params
      params.permit(:name, :email, :address, :phone, :password, :password_confirmation)
    end
    
    
    # ⬇︎[:password]と[:password_confirmation]がフォームで送られてきたら実行?
    def password_set?
      user_params[:password].present? && user_params[:password_confirmation].present? ?
      true : false
    end
end

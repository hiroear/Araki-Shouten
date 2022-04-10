class UsersController < ApplicationController
  before_action :set_user
  
  # 会員情報の編集画面へ
  # mypage_edit_users_path	GET	 /users/mypage/edit  	users#edit
  def edit
  end


# mypage_address_edit_users_path	PUT 	/users/mypage	  users#update
  def update
    @user.update_without_password(user_params)
    # update_without_passwordは deviseをインストールし使えるようになった、パスワードなしでパスワード以外の値を変更できるメソッド
    redirect_to mypage_users_url
  end


  # マイページ画面へ
  # mypage_users_path	 GET	 /users/mypage	 users#mypage
  def mypage
  end
  
  
  # お届け先の変更画面へ
  # mypage_address_edit_users_path	GET	 /users/mypage/address/edit 	users#edit_address
  def edit_address
  end
  
  
  
  private
  
    def set_user
      @user = current_user
      # current_userメソッドを使い、ユーザー自身の情報を@userに代入
    end
  
    def user_params
      params.permit(:name, :email, :address, :phone, :password, :password_confirmation)
    end
end

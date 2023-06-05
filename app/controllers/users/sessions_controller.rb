# ログイン時に使うdeviseのコントローラー
# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # devise用のストロングパラメータをコールバックで呼び出す
  before_action :configure_sign_in_params, only: [:create]
  before_action :reject_user, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end


  # POST /resource/sign_in (↓親クラスの Devise::SessionsControllerのcreateアクションを一部修正)
  def create
    # self.resource = warden.authenticate!(auth_options)  #ログイン認証後 self.resource に情報(userオブジェクト)を格納
    # logger.debug("================= users/sessions controllers create #{self.resource}")
    
    # userオブジェクトの emailカラムがテスト用の場合
    # if self.resource.email == "a@example"
    #   set_flash_message!(:notice, :signed_in)
    #   sign_in(resource_name, resource)
    #   yield resource if block_given?
    #   respond_with resource, location: after_sign_in_path_for(resource)
    #     # redirect_to root_path and return
    # end
    
    # userオブジェクトの deleted_flgカラムが false(デフォルト)の場合フラッシュメッセージと共に通常通りサインイン
    # ︎ログイン後 after_sign_in_path_for(user)アクションが呼び出され products_pathへ遷移
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end


  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end


  #ログイン後のリダイレクト先をlogin_pathからproducts_pathへ変更
  def after_sign_in_path_for(user)
    products_path
  end
 
  def after_sign_out_path_for(user)
    root_path
  end
  
  
  
  protected
  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(
      :sign_in, keys: [ :name, :postal_code, :address, :phone, :email, :password, :password_confirmation ])
  end
  
  
  # ログイン前(createアクション実行前)に実行し deleted_flgが trueの場合メッセージを表示しログイン画面へ強制遷移
  def reject_user
    @user = User.find_by(email: params[:user][:email].downcase)
      #届いたパラメータをusersテーブルの emailカラムに入れて @userに格納。downcase：大文字から小文字へ変換
      # logger.debug("================= users/sessions controllers reject_user #{@user}")
    
    if @user                   # @user変数に何か含まれていたら以下の処理を実行
      if @user.deleted_flg?    # @userの deleted_flgが trueだったら
        set_flash_message! :notice, :deleted  #devise.ja.yml内 deleted(既に退会済みです)を set_flash_messageメソッドで表示
        redirect_to new_user_session_path     #ログイン画面へ
      end
    end
  end
end

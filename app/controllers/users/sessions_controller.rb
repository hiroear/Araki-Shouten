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


  # POST /resource/sign_in (親クラスの Devise::SessionsControllerのcreateアクションに一部修正を追加)
  def create
    self.resource = warden.authenticate!(auth_options)
    
    # オブジェクト(ユーザー)のdeleted_flgがtrueであれば、flashメッセージと共にルートに遷移、処理を中断
    if self.resource.deleted_flg?
      set_flash_message!(:danger, :deleted_account)
      redirect_to root_path and return
    end
    
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
  
  
  def reject_user
    @user = User.find_by(email: params[:user][:email].downcase)  #downcase：大文字から小文字へ変換
    if @user
      if @user.deleted_flg? #@userの deleted_flgが trueだったら
        set_flash_message! :notice, :deleted  #devise.ja.ymlで設定した deleted(メッセージ)を set_flash_messageメソッドで表示
        redirect_to new_user_session_path     #ログイン画面へ
      end
    end
  end
end

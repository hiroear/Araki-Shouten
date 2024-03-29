# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  # devise用のストロングパラメータをコールバックで呼び出す
  before_action :configure_sign_in_params, only: [:new, :create, :destroy]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end
  
  #管理者としてログインした後のリダイレクト先
  def after_sign_in_path_for(admin)
    dashboard_path
  end
 
  def after_sign_out_path_for(admin)
    new_admin_session_path
  end
  
  

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(
      :sign_in, keys: [ :name, :email, :password, :password_confirmation ])
  end
end

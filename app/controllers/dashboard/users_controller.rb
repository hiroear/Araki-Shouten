class Dashboard::UsersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"
  
  
  # dashboard_users_path	GET 	/dashboard/users
  def index
    # @users = User.display_list(params[:pages])
    if params[:keyword].present?
      @keyword = params[:keyword].strip
      @users = User.search_information(@keyword).display_list(params[:pages])
    else
      @keyword = ""
      @users = User.display_list(params[:pages])
    end
  end
  
  
  # dashboard_user_path	 DELETE	 /dashboard/users/:id
  def destroy
    user = User.find(params[:id])
    deleted_flag = User.switch_flg(user.deleted_flg)  #true/false ? false : true (trueだったらfalseに / falseだったらtrueにスイッチ)
    user.update(deleted_flg: deleted_flag)
    redirect_to dashboard_users_path
  end
end

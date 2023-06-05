module ApplicationHelper
  # URLのパスが /login 又は /users/sign_inの場合 trueを返し、/dashboard/login 又は /admins/sign_inの場合 falseを返す
  def resource_is_user?
    if request.fullpath == "/dashboard/login"
      return false
    elsif request.fullpath == '/admins/sign_in'
      return false
    elsif request.fullpath == "/login"
      return true
    elsif request.fullpath == '/users/sign_in'
      return true
    end
  end
end

module ApplicationHelper
  # URLのパスに相当する部分が /login 又は /users/sign_in であればtrueを返し、/dashboard/login 又は /admins/sign_in であれば falseを返す
  def resource_is_user?
    if request.fullpath == "/dashboard/login"
      return false
    elsif request.fullpath == '/admins/sign_in'
      return false
    elsif request.fullpath == "/login" || '/users/sign_in'
      return true
    end
  end
  # request.fullpath == "/login" || '/users/sign_in' とだけ書いたら dashboard/loginにアクセスの際メソッドが効かない為上記のメソッド内容に変更
  
end

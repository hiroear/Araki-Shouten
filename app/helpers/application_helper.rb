module ApplicationHelper
  # URLのパスに相当する部分が /login であればtrueを返す
  def resource_is_user?
    request.fullpath == "/login"
  end
end

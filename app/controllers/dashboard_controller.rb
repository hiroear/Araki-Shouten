# Dashbord モデルは必要ない(元々あるDBを取得して管理する)のでコントローラ名は複数形でなくてOK
class DashboardController < ApplicationController
  layout 'dashboard/dashboard'  #dashboard専用のlayoutsファイル(layouts/dashboard/dashboard.html)を読込み
  
  def index
    
  end
end

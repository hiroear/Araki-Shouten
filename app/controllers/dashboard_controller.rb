# Dashbord モデルは必要ない(元々あるDBを取得して管理する)のでコントローラ名は複数形でなくてOK
# ダッシュボード全体のコントローラー

class DashboardController < ApplicationController
  before_action :authenticate_admin!  #ログイン管理者以外のアクセスを弾く
  layout 'dashboard/dashboard'  #dashboard専用のlayoutsファイル(layouts/dashboard/dashboard.html)を読込み
  
  def index
    
  end
end

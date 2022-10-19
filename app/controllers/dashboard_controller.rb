# Dashbord モデルは必要ない(元々あるDBを取得して管理する)のでコントローラ名は複数形でなくてOK
# ダッシュボードTOP(売上一覧) コントローラー

class DashboardController < ApplicationController
  before_action :authenticate_admin!  #管理者としてログインしていなければ何も処理せず root_pathに遷移する deviseのメソッド
  layout 'dashboard/dashboard'  #dashboard専用のlayoutsファイル(layouts/dashboard/dashboard.html)を読込み
  
  def index
    @sort = params[:sort]
    @sort_list = ShoppingCart.sort_list
    
    if @sort == "month"
      sales = ShoppingCart.get_monthly_sales    # 月単位の売上カートデータの [{配列}] を返す
      #sales = [{:period=>"2022-07", :total=>9, :count=>1, :average=>9}, {:period=>"2022-06", :total=>10, :count=>2, :average=>5}, {:period=>"2022-04", :total=>41, :count=>1, :average=>41}...]
    else
      sales = ShoppingCart.get_daily_sales      # 日単位の売上データの [{配列}] を返すクラスメソッド
    end
    #クラスメソッドは ShoppingCart.get_monthly_salesのようにクラスに対して直接使う
    
    #⬇︎ 売上一覧とページネーション
    @sales = Kaminari.paginate_array(sales).page(params[:page]).per(15)
    # 通常 Kaminariの pageメソッドや perメソッドはモデルに対してしか使えない(例：Product.page(params[:page]).per(15))
    # 変数 salesには配列が入っている為 配列に対して Kaminariのメソッドを使うには⬇︎
    # Kaminari.paginate_array(配列).page(params[:page]).per(15)  と書かなくてはならない。

  end
end

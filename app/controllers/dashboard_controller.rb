# Dashbord モデルは必要ない(元々あるDBを取得して管理する)のでコントローラ名は複数形でなくてOK
# ダッシュボードTOP(売上一覧) コントローラー

class DashboardController < ApplicationController
  before_action :authenticate_admin!
  layout 'dashboard/dashboard'  #dashboard専用layoutsファイル
  PER = 15
  
  def index
    @sort = params[:sort]
    @sort_list = ShoppingCart.sort_list         # { '日別': 'daily', '月別': 'month'}
    
    if @sort == "month"
      sales = ShoppingCart.get_monthly_sales    # 月単位の売上カートデータの [{配列}] を返す
      #sales = [{:period=>"2023-05", :total=>9, :count=>1, :average=>9}, {:period...]
    else
      sales = ShoppingCart.get_daily_sales      # 日単位の売上データの [{配列}] を返すクラスメソッド
    end
    
    @sales = Kaminari.paginate_array(sales).page(params[:page]).per(PER)
    # 通常 Kaminariの pageメソッドや perメソッドはモデルに対してしか使えない(例：Product.page(params[:page]).per(15))
    # 変数 salesには配列が入っている為 配列に対して Kaminariのメソッドを使うには Kaminari.paginate_array(配列).page(params[:page]).per(15)とする

  end
end

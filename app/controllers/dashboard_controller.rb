# Dashbord モデルは必要ない(元々あるDBを取得して管理する)のでコントローラ名は複数形でなくてOK
# ダッシュボードTOP(売上一覧) コントローラー

class DashboardController < ApplicationController
  before_action :authenticate_admin!  #ログイン管理者以外のアクセスを弾く
  layout 'dashboard/dashboard'  #dashboard専用のlayoutsファイル(layouts/dashboard/dashboard.html)を読込み
  
  def index
    @sort = params[:sort]
    @sort_list = ShoppingCart.sort_list
    
    if @sort == "month"
      sales = ShoppingCart.get_monthly_sales    # 月別売上データの [{配列}] を返すクラスメソッド
      # logger.debug("================= dashboard_controllers index #{sales}")
    else
      sales = ShoppingCart.get_daily_sales      # 日別売上データの [{配列}] を返すクラスメソッド
    end
    #クラスメソッドは ShoppingCart.get_monthly_salesのようにクラスに対して直接使う
    
    @sales = Kaminari.paginate_array(sales).page(params[:page]).per(15)    #売上一覧画面のページネーション
    # 通常 kaminariのpage・perメソッドはActive Record、つまりモデルに対してのみ使える (例：Product.page(params[:page]).per(15))
    # しかし get_monthly_sales / get_daily_salesメソッドは配列を返すメソッドの為 変数salesには配列が入っている
    # @sales = ShoppingCart.get_monthly_sales.page(params[:page]).per(15) と書きたいがこれはエラーになってしまう
    # 配列に対してkaminariのメソッドを使うには以下のように記述する⬇︎
    # @hoge = Kaminari.paginate_array(配列).page(params[:page]).per(1ページあたりの表示数)
    # logger.debug("================= dashboard_controllers index #{@sales}")

  end
end

# ダッシュボード / 受注一覧
class Dashboard::OrdersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"

  def index
    @code = params[:code]  #これ抜けてたのになんで動く？ (注文番号)
    
    if params[:code].present?
      @orders = ShoppingCart.search_bought_carts_by_ids(params[:code]).page(params[:page]).per(15)
      # ShoppingCart.where(buy_flag: true).where("params[:code] LIKE ?", "%#{params[:code]}%").page(params[:page]).per(15)
    else
      @orders = ShoppingCart.bought_carts.page(params[:page]).per(15)
      # ShoppingCart.where(buy_flag: true).page(params[:page]).per(15)
    end
  end
end

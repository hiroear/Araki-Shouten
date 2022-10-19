# ダッシュボード / 受注一覧
class Dashboard::OrdersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"

  def index
    if params[:code].present?
      @code = params[:code]  #これ抜けてたのになんで動く？ (注文番号)
      @orders = ShoppingCart.search_bought_carts_by_ids(@code).page(params[:page]).per(15)
      # ShoppingCart.where(buy_flag: true).where("params[:code] LIKE ?", "%#{params[:code]}%").page(params[:page]).per(15)
    elsif params[:from_date] && params[:to_date].present?
      # @date = params[:date]
      # @orders = ShoppingCart.where(buy_flag: true).where("updated_at LIKE ?", "%#{@date}%").page(params[:page]).per(15)
      @from_date = params[:from_date]
      @to_date = params[:to_date]
      @orders = ShoppingCart.where(buy_flag: true).where(updated_at: @from_date..@to_date).page(params[:page]).per(15)
    else
      
      @orders = ShoppingCart.bought_carts.page(params[:page]).per(15)
      # ShoppingCart.where(buy_flag: true).page(params[:page]).per(15)
    end
  end
end

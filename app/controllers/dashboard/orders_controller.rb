# ダッシュボード / 受注一覧
class Dashboard::OrdersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"
  PER =15

  def index
    if params[:code].present?
      @code = params[:code]
      @orders = ShoppingCart.search_bought_carts_by_ids(@code).order(updated_at: "desc").page(params[:page]).per(PER)
        # ShoppingCart.where(buy_flag: true).where("params[:code] LIKE ?", "%#{params[:code]}%")
        
    elsif params[:from_date] && params[:to_date].present?
      @from_date = params[:from_date]
      @to_date = params[:to_date]
        # logger.debug("================== to date = #{@to_date.to_datetime.end_of_day}")
      @orders = ShoppingCart.bought_carts.where(updated_at: @from_date..@to_date.to_datetime.end_of_day).order(updated_at: "desc").page(params[:page]).per(PER)
        # .where(updated_at: @from_date..@to_date)では 1日のみのスポット検索ができなかった
        # .where("updated_at between '#{@from_date}' and '#{@to_date} 23:59:59'") という書き方もできる
      @from_date = ''
      @to_date = ''
      
    elsif params[:customer_name].present?
      @customer_name = params[:customer_name].strip
      user = User.where("name LIKE ?", "%#{@customer_name}%")
        # logger.debug("================== user = #{user}")
      user_id = User.where(id: user)  # userにはインスタンスが入っている為 id検索が可能
      @orders = ShoppingCart.search_bought_carts_by_user(user_id).order(updated_at: "desc").page(params[:page]).per(PER)
      @customer_name = ''
    else
      @orders = ShoppingCart.bought_carts.order(updated_at: "desc").page(params[:page]).per(PER)
        # ShoppingCart.where(buy_flag: true)
    end
  end
  
  
  def show
    @cart = ShoppingCart.find(params[:id])
    @cart_items = ShoppingCartItem.user_cart_items(@cart.id)
      # shoppingcartItem.where(owner_id: @cart.id)
  end
end

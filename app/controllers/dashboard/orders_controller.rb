# ダッシュボード / 受注一覧
class Dashboard::OrdersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"
  PER =15

  def index
    if params[:code].present?
      @code = params[:code]
      @orders = ShoppingCart.includes(:user, :shopping_cart_items).search_bought_carts_by_ids(@code).order(updated_at: "desc").page(params[:page]).per(PER)
        # ShoppingCart.where(buy_flag: true).where("params[:code] LIKE ?", "%#{params[:code]}%")
        
    elsif params[:from_date] && params[:to_date].present?
      @from_date = params[:from_date]
      @to_date = params[:to_date]
        # logger.debug("================== to date = #{@to_date.to_datetime.end_of_day}")
      @orders = ShoppingCart.includes(:user, :shopping_cart_items).bought_carts.where(updated_at: @from_date..@to_date.to_datetime.end_of_day).order(updated_at: "desc").page(params[:page]).per(PER)
        # .where(updated_at: @from_date..@to_date)では 1日のみのスポット検索ができなかった
        # .where("updated_at between '#{@from_date}' and '#{@to_date} 23:59:59'") という書き方もできる
      @from_date = ''
      @to_date = ''
      
    elsif params[:customer_name].present?
      @customer_name = params[:customer_name].strip
      user = User.where("name LIKE ?", "%#{@customer_name}%")
        # logger.debug("================== user = #{user}")
      user_id = User.where(id: user)  # userにはインスタンスが入っている為 id検索が可能
      @orders = ShoppingCart.includes(:user, :shopping_cart_items).where(user_id: user_id).bought_carts.order(updated_at: "desc").page(params[:page]).per(PER)
      @customer_name = ''
    else
      @orders = ShoppingCart.includes(:user, :shopping_cart_items).bought_carts.order(updated_at: "desc").page(params[:page]).per(PER)
    end
  end
  
  
  def show
    @cart = ShoppingCart.find(params[:id])
    @cart_items = ShoppingCart.includes(:shopping_cart_items).where(shopping_cart_items: {owner_id: @cart.id})
    # @cart_items = ShoppingCart.includes(:shopping_cart_items, :products).where(shopping_cart_items: {owner_id: @cart.id}, products: {id: shopping_cart_items.item_id})
    
    # @cart_items = ShoppingCartItem.user_cart_items(@cart.id)  # shoppingcartItem.where(owner_id: @cart.id)
    # logger.debug("================== orders_controller = #{@cart_items}")
      
    # cart_item_ids = ShoppingCartItem.where(owner_id: @cart.id).select("shopping_cart_items.item_id").to_a
      # [#<ShoppingCartItem id: nil, item_id: 1>, #<ShoppingCartItem id: nil, item_id: 3>...
    # @cart_item_ids = cart_item_ids.map { |c| c.item_id }.join(',')           # 1,3,2,28,7,32
      
    # @cart_items = ShoppingCartItem.includes(:products).where(products: {id: @cart_item_ids}).to_a
    
    # @product_cart_items = Product.includes(:shopping_cart_item).references(:shopping_cart_items).where(shopping_cart_items: {owner_id: @cart.id}).where(id: cart_items).with_attached_image
  end
end

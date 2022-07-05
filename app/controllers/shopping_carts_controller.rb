class ShoppingCartsController < ApplicationController
  before_action :set_cart, only: %i[index create destroy]
  
  # 現在カートに入っている商品一覧とこれまで購入した商品履歴(カートの履歴)を表示
  def index
    logger.debug("============================== shopping_carts controllers index #{@user_cart}")
    @user_cart_items = ShoppingCartItem.user_cart_items(@user_cart)  # ShoppingCartItem.where(owner_id: @user_cart)
    # @user_cartにはまだ注文が確定していないカートのデータ全てが入っている(その中に owner_id含む)
    # user_cart_itemsメソッド :カートに入っている全ての商品のデータを返す(shopping_cart_itemモデルに定義)
  end
  
  
  # 過去の注文履歴(カートの履歴)を表示
  def show
    @cart = ShoppingCart.find(user_id: current_user)
    # ログインユーザーのカートデータをDBから呼び出し @cartに代入
  end
  
  
  # カートに商品を追加する
  def create
    @product = Product.find(product_params[:product_id])
    logger.debug("============================== shopping_carts controllers create #{@product}")
    @user_cart.add(@product, product_params[:price].to_i, product_params[:quantity].to_i)
    # ⬆︎acts_as_shopping_cartの addメソッドで、送信されたデータを元にして商品をカートに追加
    redirect_to cart_users_path
    # 商品をカートに追加したらカートの一覧ページ(カート中身を表示するページ)にリダイレクト
  end
  
  
  def update
  end
  
  
  # カート内の商品を注文する
  def destroy
    @user_cart.buy_flag = true   #カートの注文済みフラグをtrueにして注文処理
    @user_cart.save              #DBに保存
    redirect_to cart_users_url   #カート一覧ページにリダイレクト(空のカート)
  end
  
  
  private
    def product_params
      params.permit(:product_id, :price, :quantity)
    end
    
    def set_cart
      @user_cart = ShoppingCart.set_user_cart(current_user)
      # set_user_cartメソッド :まだ注文が確定していないカートのデータを返し、データがなければ新しく作る(ShoppingCartモデルに定義)
    end
end

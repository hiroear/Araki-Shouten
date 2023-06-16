class ShoppingCartsController < ApplicationController
  before_action :set_user, only: %i[index show destroy]
  before_action :set_cart, only: %i[index create destroy]
  
  # 現在カートに入っている商品一覧とこれまで購入した商品履歴(カートの履歴)を表示
  def index
    # logger.debug("============================== shopping_carts controllers index #{@user_cart}")
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    
    # @user_cartにはまだ注文が確定していないカートのインスタンスが入っている
    @user_cart_items = ShoppingCart.includes(:shopping_cart_items).where(shopping_cart_items: {owner_id: @user_cart.id})
    
    #︎確認
    if @user.token != ""
      @card = Payjp::Customer.retrieve(@user.token).cards.all(limit: 1).data[0]
    end
    logger.debug("============================== @card.present? #{@card}")
    logger.debug("============================== @user.token #{@user.token}")
  end
  
  
  # 過去の注文履歴(カートの履歴)を表示
  def show
    @cart = ShoppingCart.find(user_id: @user)
    # ログインユーザーのカートデータをDBから呼び出し @cartに代入
  end
  
  
  # カートに商品を追加する
  def create
    @product = Product.find(shopping_cart_product_params[:product_id])
    logger.debug("============================== shopping_carts controllers create #{@product}")
    @user_cart.add(@product, shopping_cart_product_params[:price].to_i, shopping_cart_product_params[:quantity].to_i)
    # ↑︎acts_as_shopping_cartの addメソッドで、送信されたデータを元に商品をカートに追加
    redirect_to cart_users_path
    # 商品をカートに追加後カート一覧ページへリダイレクト
  end
  
  
  def update
  end
  
  
  # カート内のアイテムを削除
  def delete_item
    item = ShoppingCartItem.find(params[:id])
    item.destroy
    redirect_to cart_users_path
  end
  
  
  # カート内の商品を注文する
  def destroy
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    
    if @user.token != ""  # tokenが空でなければ PAY.JPに顧客id・購入価格・通貨の種類を渡し、単発決済
      Payjp::Charge.create(
        :customer => @user.token,
        :amount => @user_cart.total.to_i,
        :currency => 'jpy'
      )
    else  # tokenが空の場合 Customerのカード情報を新規登録・tokenを生成・保存 → 単発決済
      cu = Payjp::Customer.create
      cu.cards.create(:card => params["payjp-token"])  # cu = 新規customer
      @user.token = cu.id                              # customer.id = Payjp側では"customer"の値
      @user.save
      #ここから単発決済
      Payjp::Charge.create(
        :customer => @user.token,
        :amount => @user_cart.total.to_i,
        :currency => 'jpy'
      )
    end
    
    @user_cart.buy_flag = true     #カートの注文済みフラグをtrueにして注文処理
    @user_cart.save                #DBに保存
    
    redirect_to cart_users_url     #カート一覧ページにリダイレクト(空のカートになる)
  end
  
  
  private
    def set_user
      @user = current_user
    end
    
    def shopping_cart_product_params
      params.permit(:product_id, :price, :quantity)
    end
    
    def set_cart
      @user_cart = ShoppingCart.set_user_cart(@user)
      # set_user_cart :まだ注文が確定していないカートのデータを返し、データがなければ新しく作る(ShoppingCartモデルに作成される)
    end
end

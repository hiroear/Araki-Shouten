# マイページ関連
class UsersController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!
  
  
  # 会員情報の編集画面
  # mypage_edit_users_path	GET	 /users/mypage/edit  	users#edit
  def edit
  end


  # 会員情報編集・更新
  # mypage_users_path 	PUT  /users/mypage	  users#update
  def update
    #logger.debug("============================== users controllers update before #{user_params}")
    result = @user.update_without_password(user_params)
      # update_without_password :パスワードなしでパスワード以外の値を変更できるdeviseのメソッド
    logger.debug("=========================== users controllers update after error #{@user.errors.messages[:name].present?}")

    # redirect_to mypage_users_url
    if result
      redirect_to request.referer, notice: '会員情報が更新されました。'
    else
      render 'users/edit'
    end
  end


  # マイページ一覧画面
  # mypage_users_path	 GET	 /users/mypage	 users#mypage
  def mypage
  end
  
  
  # お届け先変更画面
  # mypage_address_edit_users_path	GET	 /users/mypage/address/edit 	users#edit_address
  def edit_address
  end
  
  
  # パスワード編集・更新
  # mypage_password_users_path	 PUT 	/users/mypage/password   users#update_password
  def update_password
    #logger.debug("==================== password change #{params[:password]}")
    
    if password_set? #true
      @user.update_password({password: params[:password], password_confirmation: params[:password_confirmation]}) 
      flash[:notice] = "パスワードは正しく更新されました。"
      redirect_to root_url
    else            #false
      @user.errors.add(:password, "パスワードに不備があります。")
      render "edit_password"
    end
  end
  
  
  # パスワード編集画面へ
  # mypage_edit_password_users_path	 GET	 /users/mypage/edit_password   users#edit_password
  def edit_password
  end
  
  
  # mypage_favorite_users_path 	GET	 /users/mypage/favorite  users#favorite
  def favorite
    @favorites = @user.likees(Product)
    # likees :socializationのメソッド
    # likees(Product) :ログインユーザーがお気に入りに追加した全商品データを取得
  end
  
  
  # 退会処理  mypage_delete_users_path	DELETE	/users/mypage/delete  users#destroy
  def destroy
    @user.deleted_flg = User.switch_flg(@user.deleted_flg) # @user.deleted_flg ? false : true
    @user.update(deleted_flg: @user.deleted_flg)
    
    if @user.deleted_flg?  #@user.deleted_flg が trueだったらログアウトして root画面へ遷移
      reset_session
      redirect_to root_path
    end
  end
  
  
  # マイページ > 注文履歴を表示
  def cart_history_index
    @orders = ShoppingCart.search_bought_carts_by_user(@user).page(params[:page]).per(13)
      # ShoppingCart.where(buy_flag: true).where(user_id: current_user)
  end
  
  
  # マイページ > 注文履歴 > 注文履歴詳細 を表示
  def cart_history_show
    @cart = ShoppingCart.find(params[:num])
    @cart_items = ShoppingCartItem.user_cart_items(@cart.id)
      # shoppingcartItem.where(owner_id: @cart.id)
  end
  
  
  # クレジットカード登録画面　mypage_register_card_users_path  GET	/users/mypage/register_card   users#register_card
  def register_card
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    # @count = 0
    card_info = {}
    
    if @user.token != ""  # @userの tokenが空でなければ
      result = Payjp::Customer.retrieve(@user.token).cards.all(limit: 1).data[0]
      @count = Payjp::Customer.retrieve(@user.token).cards.all.count  #1 確認
      
      card_info[:brand] = result.brand
      card_info[:exp_month] = result.exp_month
      card_info[:exp_year] = result.exp_year
      card_info[:last4] = result.last4
    end
    
    @card = card_info  #{:brand=>"Visa", :exp_month=>4, :exp_year=>2024, :last4=>"4242"}
    # logger.debug("==================== register_card #{@card}")
  end
  
  
  # クレジットカード更新・登録  mypage_token_users_path  POST 	/users/mypage/token  users#token
  def token
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    customer = @user.token
    
    if @user.token != ""
      cu = Payjp::Customer.retrieve(customer)  # usersテーブルの tokenカラムに該当する PayjpのCustomer情報を retrieveで取得
      delete_card = cu.cards.retrieve(cu.cards.data[0]["id"])
      delete_card.delete
      cu.cards.create(:card => params["payjp-token"])
    else
      cu = Payjp::Customer.create
      cu.cards.create(:card => params["payjp-token"])
      @user.token = cu.id
      @user.save
    end
    redirect_to mypage_users_url
  end
  
  
  
  private
    def set_user
      @user = current_user
    end
    
  
    def user_params
      params.permit(:name, :email, :address, :postal_code, :phone, :password, :password_confirmation)
      # params.require(:モデル名).permit(:キー名)
      # .requireメソッドがデータのオブジェクト名を定め、
      # .permitメソッドで変更・保存の処理ができる。キーを指定(paramsで取得したパラメータに保存の許可処理)
      
      # require(:user)なら params[:user][:name]
      # requireなしなら {params[:name] => "荒木"}
    end
    
    
    def password_set?
      params[:password].present? && params[:password_confirmation].present? ?
      true : false
    end
end

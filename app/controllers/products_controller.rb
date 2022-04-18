class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite]
  
  # GET  prefix:products  /products
  def index
    # @products = Product.page(params[:page]).per(PER)
      #kaminariをインストールして.pageメソッドと.perメソッドを使えるようになった
      
    # @products = Product.display_list(category_params, params[:page])
      # 例：Product.where(category_id: 1).page(2).per(15)
      #_sidebarのカテゴリ名のリンクから受け取った値(category.id )を使って商品一覧に表示する商品をカテゴリ毎に絞り込み表示している
      #Productモデルのdisplay_listメソッドで、条件によって一覧画面に表示する商品を変更((params[:category], params[:page]) or ("none", params[:page])のどちらか)
      #⬆︎条件: category_paramsアクションによって params[:category]という値が存在すればその値を返し、存在しなければ"none"という文字列を返す
      #display_listメソッドを使うには(カテゴリ, 現在のページ)の2つの引数が必要
      
    # @category = Category.request_category(category_params)
      #_sidebarのカテゴリ名のリンクから受け取った値(category.id)を元に category_paramsで条件分岐
      # Categoryモデル内の request_categoryメソッドで category.idが存在していれば indexアクション内での処理は @category = Category.find(カテゴリid)になり、インスタンス変数@categoryにカテゴリのデータが代入される
    
    if sort_params.present?  #sort_paramsの情報が渡ってきた時(並び替え時)
      #並び替えをした時の商品データを返す
      @sorted = sort_params[:sort]
              # params[:sort_category]
      @category = Category.request_category(sort_params[:sort_category])
      # @category = Category.find(1)
      
      @products = Product.sort_products(sort_params, params[:page])
      
    elsif params[:category].present?  #sort_paramsは存在せず、params[:category]が存在する時(カテゴリを選択時）
      #選択したカテゴリに属する商品データを返す
      @category = Category.request_category(params[:category])
      @products = Product.category_products(@category, params[:page])
      
    else  #どちらも存在しない時(indexページにアクセス時)
      #indexページにアクセスしたときに表示させる商品データを返す
      #indexページではカテゴリによる表示をさせないようインスタンス変数@categoryには値を代入しない
      @products = Product.display_list(params[:page])
    end
    
    @categories = Category.all
    @major_category_names = Category.major_categories
      #Categoryモデルのmajor_categoriesメソッドでカテゴリを呼び出し、@major_category_namesに代入
      
    @sort_list = Product.sort_list
  end

  # GET  prefix:product  /products/1
  def show
    @reviews = @product.reviews
      #商品に関する全てのレビューを取得
    @review = @reviews.new
      #レビューのフォーム(showテンプレート)にnewで渡してsubmitさせる
  end

  # GET  prefix:new_product  /products/new
  def new
    @product = Product.new
    @categories = Category.all
  end

  # POST  prefix:products  /products
  def create
    @product = Product.new(product_params)
    @product.save
    redirect_to product_url(@product)
      # ⬆︎個別の商品ページに遷移(showアクション)引数の@productは表示させたいデータのIDを渡している
  end

  # GET  prefix:edit_product  /products/1/edit
  def edit
    @categories = Category.all
  end

  # PATCH/PUT  prefix:product  /products/1
  def update
    @product.update(product_params)      #updateメソッドの引数にproduct_paramsを渡し商品データを更新
    redirect_to product_url(@product)
      # showテンプレートにリダイレクト
  end

  # DELETE  prefix:product  /products/1
  def destroy
    @product.destroy
    redirect_to products_url #indexページに遷移するので引数はなし
  end
  
  
  def favorite
    # user = current_user  ⬅︎テキストには説明文で必要と書いてある
    current_user.toggle_like!(@product)
      # ユーザーがその商品をまだお気に入りに追加していなければ追加し、すでに追加していればそれを外す処理
    redirect_to product_url @product
      # showテンプレートにリダイレクト
  end
  
  
  private
    def set_product
      @product = Product.find(params[:id])
    end
  
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id)
        # collection_select()メソッドにカテゴリIDを渡すので、ストロングパラメータのホワイトリストにもcategory_idを追加
    end
    
    #⬇︎ params[:category]という値が存在すればその値を返し、存在しなければ"none"という文字列を返す三項演算子
    # def category_params
    #   params[:category].present? ? params[:category]
    #                             : "none"
    # end
    
    def sort_params
      params.permit(:sort, :sort_category)
      #index の並び替え部分 :sort と :sort_category の情報をjavascriptによるsubmit()で取得
    end
end

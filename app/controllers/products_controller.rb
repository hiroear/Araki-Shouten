class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite]
  
  # GET  prefix:products  /products
  def index
    # @products = Product.page(params[:page]).per(PER) (kaminariの.pageメソッドと.perメソッド)
      
    # @products = Product.display_list(category_params, params[:page])
      # 例：Product.where(category_id: 1).page(2).per(15)
      #_sidebarのカテゴリ名のリンクから受け取った値(category.id )を使って商品一覧に表示する商品をカテゴリ毎に絞り込み表示している
      #Productモデルのdisplay_listメソッドで、条件によって一覧画面に表示する商品を変更((params[:category], params[:page]) or ("none", params[:page])のどちらか)
      #⬆︎条件: category_paramsアクションによって params[:category]という値が存在すればその値を返し、存在しなければ"none"という文字列を返す
      #display_listメソッドを使うには(カテゴリ, 現在のページ)の2つの引数が必要
      
    # @category = Category.request_category(category_params)
      #_sidebarのカテゴリ名のリンクから受け取った値(category.id)を元に category_paramsで条件分岐
      # Categoryモデル内の request_categoryメソッドで category.idが存在していれば indexアクション内での処理は @category = Category.find(カテゴリid)になり、インスタンス変数@categoryにカテゴリのデータが代入される
    
    if sort_params.present?  #sort_paramsが渡ってきた時(並び替え時) 並び替え後の商品データを返す
      @sorted = sort_params[:sort]  # params[:sort_category]
      @category = Category.request_category(sort_params[:sort_category]) # @category = Category.find(1)
      @products = Product.sort_products(sort_params, params[:page])
    elsif params[:category].present?  #params[:category]だけが渡ってきた時(サイドバーカテゴリ選択時）
      @category = Category.request_category(params[:category])     # @category = Category.find(1)
      @products = Product.category_products(@category, params[:page])
    else  #通常の商品一覧(indexページにアクセス)
      @products = Product.display_list(params[:page])  #Product.where(category_id: 1).page(2).per(15)
      logger.debug("================= products controllers index #{@products}")
    end
    
    @categories = Category.all
    @major_category_names = Category.major_categories
    #Categoryモデルのmajor_category_nameカラムのデータのみを major_category_namesに代入
      
    @sort_list = Product.sort_list
  end


  # GET  prefix:product  /products/1
  def show
    # ⬇︎変更 @reviews = @product.reviews.all  #該当の商品に関する全てのレビューを取得 (allは省略可)
    @reviews = @product.reviews_with_id  #idを持っているReviewオブジェクトのみ取得 (@product.reviews.all.where.not(product_id: nil))
    @review = @reviews.new              # @reviews の新しいインスタンスを生成し、レビューフォームに渡す
    @star_repeat_select = Review.star_repeat_select  # ★★★★★ 評価リスト Reviewモデルに定義
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
    redirect_to product_url(@product)    #個別の商品ページに遷移。引数の(@product)は表示させたいproduct_id
  end


  # GET  prefix:edit_product  /products/1/edit
  def edit
    @categories = Category.all
  end


  # PATCH/PUT  prefix:product  /products/1
  def update
    @product.update(product_params)      #引数に(product_params)を渡し商品データを更新
    redirect_to product_url(@product)
  end


  # DELETE  prefix:product  /products/1
  def destroy
    @product.destroy
    redirect_to products_url  #indexページに遷移するので引数(id)はなし
  end
  
  
  # GET  favorite_product_path 	/products/:id/favorite
  def favorite
    current_user.toggle_like!(@product)
      # ユーザーがその商品をまだお気に入りに追加していなければ追加、すでに追加していればそれを外す処理
    redirect_to product_url @product    # showテンプレートにリダイレクト引数の()は省略可
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
      #index の並び替え部分からの params[:sort]、params[:sort_category] をjavascriptによるsubmit()で取得
    end
end

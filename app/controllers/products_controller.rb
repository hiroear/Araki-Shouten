class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite]
  
  # GET  prefix:products  /products
  def index
    # @products = Product.page(params[:page]).per(PER)
      #kaminariをインストールして.pageメソッドと.perメソッドを使えるようになった
      
    @products = Product.display_list(category_params, params[:page])
      #_sidebarのカテゴリ名のリンクから受け取った値(category.id )を使って商品一覧に表示する商品をカテゴリ毎に絞り込み表示している
      #Productモデルのdisplay_listメソッドで、条件によって一覧画面に表示する商品を変更((params[:category], params[:page]) or ("none", params[:page])のどちらか)
      #⬆︎条件: category_paramsアクションによって params[:category]という値が存在すればその値を返し、存在しなければ"none"という文字列を返す
      #display_listメソッドを使うには(カテゴリ, 現在のページ)の2つの引数が必要
      
    @category = Category.request_category(category_params)
      #_sidebarのカテゴリ名のリンクから受け取った値(category.id)を元に category_paramsで条件分岐
      # Categoryモデル内の request_categoryメソッドで category.idが存在していれば indexアクション内での処理は @category = Category.find(カテゴリid)になり、インスタンス変数@categoryにカテゴリのデータが代入される
    @categories = Category.all
    @major_category_names = Category.major_categories
      #Categoryモデルのmajor_categoriesメソッドでカテゴリを呼び出し、@major_category_namesに代入
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
    def category_params
      params[:category].present? ? params[:category]
                                 : "none"
    end
end

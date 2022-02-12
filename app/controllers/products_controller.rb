class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :favorite]
  PER = 15
    #コードがマジックナンバーばかりになってしまうと、システムを改修したいときに苦労する為、極力マジックナンバーは避ける為定義
  
  # GET  prefix:products  /products
  def index
    @products = Product.page(params[:page]).per(PER)
    #kaminariをインストールして.pageメソッドと.perメソッドを使えるようになった
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
end

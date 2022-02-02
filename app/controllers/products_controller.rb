class ProductsController < ApplicationController
  
  # GET  prefix:products  /products
  def index
    @products = Product.all
  end

  # GET  prefix:product  /products/1
  def show
    @product = Product.find(params[:id])
    # 商品データを代入したインスタンス変数をshowビューへ渡す
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
    @product = Product.find(params[:id])
    @categories = Category.all
  end

  # PATCH/PUT  prefix:product  /products/1
  def update
    @product = Product.find(params[:id]) #更新前の商品データが @productに格納される
    @product.update(product_params)      #updateメソッドの引数にproduct_paramsを渡し商品データを更新
    redirect_to product_url(@product)
  end

  # DELETE  prefix:product  /products/1
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_url #indexページに遷移するので引数はなし
  end
  
  private
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id)
      # collection_select()メソッドにカテゴリIDを渡すので、ストロングパラメータのホワイトリストにもcategory_idを追加
    end
end

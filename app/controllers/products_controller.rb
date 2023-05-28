class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :favorite]
  
  # GET  products  /products
  def index
    if params[:keyword].present?  #キーワード検索
      @keyword = params[:keyword].strip
      @products = Product.search_product(@keyword).display_list(params[:page])
    elsif sort_params.present?  #カテゴリ選択時の並べ替え
      @sorted = sort_params[:sort]  # params[:sort_category]
      @category = Category.request_category(sort_params[:sort_category]) # @category = Category.find(1)
      @products = Product.sort_products(sort_params, params[:page])
    elsif params[:category].present?  #params[:category]だけが渡ってきた時(サイドバーカテゴリ選択時）
      @category = Category.request_category(params[:category])     # @category = Category.find(1)
      @products = Product.category_products(@category, params[:page])
    else  #通常の商品一覧 (indexページ)
      @products = Product.display_list(params[:page])  #Product.where(category_id: 1).page(2).per(15)
      # logger.debug("================= products controllers index #{@products}")
    end
    
    @categories = Category.all
    @major_category_names = Category.major_categories
    #Categoryモデルのmajor_category_nameカラムのデータのみを major_category_namesに代入
      
    @sort_list = Product.sort_list
  end


  # GET  product  /products/1
  def show
    # @reviews = @product.reviews_with_id  #idを持っているReviewオブジェクトのみ取得 (@product.reviews.all.where.not(product_id: nil))
    @reviews = @product.reviews.all.where.not(product_id: nil)  #SQLの NOTは「〜以外」
    @review = @reviews.new                           # @reviews の新しいインスタンスを生成し、レビューフォームに渡す
    @star_repeat_select = Review.star_repeat_select  # ★★★★★ 評価リスト Reviewモデルに定義
    @categories = Category.all
    @major_category_names = Category.major_categories
  end


  # DELETE  product_path  /products/1
  # def destroy
  #   @product.destroy
  #   redirect_to products_url
  # end
  
  
  # GET  favorite_product_path 	/products/:id/favorite
  def favorite
    current_user.toggle_like!(@product)
      # ユーザーがその商品をまだお気に入りに追加していなければ追加、すでに追加していればそれを外す処理
    redirect_to request.referer
  end
  
  
  private
  
    def set_product
      @product = Product.find(params[:id])
    end
  
  
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id)
        # collection_select()メソッドにカテゴリIDを渡すので、ストロングパラメータのホワイトリストにもcategory_idを追加
    end
    
    
    def sort_params
      params.permit(:sort, :sort_category)
      #index の並び替え部分からの params[:sort]、params[:sort_category] をjavascriptによるsubmit()で取得
    end
end

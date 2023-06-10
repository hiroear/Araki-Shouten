class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :favorite]
  
  # GET  products  /products
  def index
    #キーワード検索
    if params[:keyword].present?
      @keyword = params[:keyword].strip
      @products = Product.search_product(@keyword).order(id: 'asc').display_list(params[:page])
      
    #カテゴリ選択後の並び替えフォーム
    elsif sort_params.present?
      @sorted = sort_params[:sort]  # params[:sort_category]
      @category = Category.request_category(sort_params[:sort_category]) # Category.find(1)
      @products = Product.sort_products(sort_params, params[:page])
      
    #サイドバーカテゴリ選択時  params[:category]だけが渡ってきた時
    elsif params[:category].present?
      @category = Category.request_category(params[:category])
      @products = Product.category_products(@category, params[:page]) # Product.where(category_id: @category).order(id: 'asc')
      
    #該当のメジャーカテゴリーに属する商品のみ商品一覧に表示
    elsif params[:major_category_id].present?
      major_category_id = params[:major_category_id]
      category_ids = Category.find_category_ids(major_category_id)
      @products = Product.products_by_major_category(category_ids, params[:page])
      @product_length = Product.products_length_by_major_category(category_ids)
      @major_category = MajorCategory.find(major_category_id)
      
    else  #通常の商品一覧 (/products)
      @products = Product.order(id: 'asc').display_list(params[:page])
      @product_length = Product.all
      # logger.debug("================= products controllers index #{@products}")
    end
    
    @categories = Category.all
    @major_category_names = Category.major_categories   #Category.pluck(:major_category_name).uniq 
      
    @sort_list = Product.sort_list
  end


  # GET  product  /products/1
  def show
    @reviews = @product.reviews_with_id              #idを持っているReviewオブジェクトのみ取得 (@product.reviews.all.where.not(product_id: nil))
    @review = @reviews.new                           # @reviews の新しいインスタンスを生成し、レビューフォームに渡す
    @star_repeat_select = Review.star_repeat_select  # ★★★★★ 評価リスト
    @category = Category.find(@product.category_id)
    @categories = Category.all
    @major_category_names = Category.major_categories
  end
  
  
  # GET  favorite_product_path 	/products/:id/favorite
  def favorite
    current_user.toggle_like!(@product)
      # toggle_like!(@product): ユーザーがその商品をお気に入りしていなければ追加し、既に追加していれば外す
    redirect_to request.referer
  end
  
  
  private
  
    def set_product
      @product = Product.find(params[:id])
    end
  
  
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id)
    end
    
    
    def sort_params
      params.permit(:sort, :sort_category)
      #index の並び替え部分からの params[:sort]、params[:sort_category] をjavascriptによるsubmit()で取得
    end
end

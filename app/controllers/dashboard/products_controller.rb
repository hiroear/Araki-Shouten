# ダッシュボード/商品管理/商品一覧　コントローラー
class Dashboard::ProductsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_product, only: %w[edit update destroy]
  layout 'dashboard/dashboard'
  
  # dashboard_products_path	 GET	/dashboard/products  dashboard/products#index
  def index
    @sorted = ''
    @sort_list = Product.sort_list
    
    if params[:sort].present?
      @sorted = params[:sort] #選択された sort_listの内容(例：'price desc')
    end
    
    if params[:keyword].present?
      keyword = params[:keyword].strip  #strip :文字列先頭と末尾の空白文字を全て取り除いた文字列を生成して返す(全角スペースは削除されない)
      @total_count = Product.search_for_id_and_name(keyword).count
        # Product.where('name LIKE ?', '%#{keyword}%').or(where('id LIKE ?', '%#{keyword}%')).count
      @products = Product.search_for_id_and_name(keyword).display_list(params[:pages])
        # Product.where('name LIKE ?', '%#{keyword}%').or(where('id LIKE ?', '%#{keyword}%')).page(page).per(15)
    else
      @total_count = Product.count
      @products = Product.sort_order(@sorted).display_list(params[:page])
        # Product.order('price desc').page(page).per(PER)
    end
  end
  
  
  # new_dashboard_product_path	GET 	/dashboard/products/new 	dashboard/products#new
  def new
    @product = Product.new
    @categories = Category.all
  end
  
  
  # dashboard_products_path	 POST 	/dashboard/products 	dashboard/products#create
  def create
    @product = Product.new(product_params)
    @product.save
    redirect_to dashboard_products_path  #商品管理一覧
  end
  
  
  # edit_dashboard_product_path	 GET	/dashboard/products/:id/edit   dashboard/products#edit
  def edit
    @categories = Category.all
  end
  
  
  # dashboard_product_path	PUT	 /dashboard/products/:id   dashboard/products#update
  def update
    @product.update(product_params)
    redirect_to dashboard_products_path
  end
  
  
  # dashboard_product_path	DELETE	/dashboard/products/:id   dashboard/products#destroy
  def destroy
    @product.destroy
    redirect_to dashboard_products_path
  end
  
  
  private
    def set_product
      @product = Product.find(params[:id])
    end
    
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id)
    end
end

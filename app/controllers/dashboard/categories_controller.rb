# ダッシュボード/カテゴリ管理　コントローラー
class Dashboard::CategoriesController < ApplicationController
  before_action :authenticate_admin!, except: :index  #ログイン管理者以外のアクセスを弾く(indexアクション以外)
  before_action :set_category, only: %w[show edit update destroy]
  layout 'dashboard/dashboard'
  
  
  # dashboard_categories_path	 GET 	/dashboard/categories  dashboard/categories#index
  def index
    @categories = Category.display_list(params[:page])
    logger.debug("================= dashboard/categories controllers index #{@categories}")
    @category = Category.new
    @major_categories = MajorCategory.all
  end
  
  
  # dashboard_category_path	GET 	/dashboard/categories/:id   dashboard/categories#show
  def show
  end
  
  
  # dashboard_categories_path	 POST	/dashboard/categories  dashboard/categories#create
  def create
    category = Category.new(category_params)
    category.save
    redirect_to dashboard_categories_path   #indexアクションへ遷移
  end
  
  
  # edit_dashboard_category_path	GET	/dashboard/categories/:id/edit	dashboard/categories#edit
  def edit
    @major_categories = MajorCategory.all
  end
  
  
  # dashboard_category_path  PUT	 /dashboard/categories/:id   dashboard/categories#update
  def update
    logger.debug("================= dashboard/categories controllers update #{category_params}")
    @category.update(category_params)
    @category.save
    redirect_to dashboard_categories_path
  end
  
  
  # dashboard_category_path  DELETE	/dashboard/categories/:id   dashboard/categories#destroy
  def destroy
    @category.destroy
    redirect_to dashboard_categories_path
  end
  
  
  
  private
    def set_category
      @category = Category.find(params[:id])
    end
    
    
    def category_params
      params.require(:category).permit(:name, :description, :major_category_name, :major_category_id)
    end
end

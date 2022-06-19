class Dashboard::MajorCategoriesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_major_category, only: %w[show edit update destroy]
  layout 'dashboard/dashboard'
  
  
  # dashboard_major_categories_path	  GET 	/dashboard/major_categories
  def index
    @major_categories = MajorCategory.display_list(params[:pages])  #MajorCategory.page(page).per(15)
    @major_category = MajorCategory.new
  end
  
  
  # dashboard_major_category_path	 GET	 /dashboard/major_categories/:id
  def show
  end
  
  
  # dashboard_major_categories_path	 POST 	/dashboard/major_categories
  def create
    major_category = MajorCategory.new(major_category_params)
    major_category.save
    redirect_to dashboard_major_categories_path
  end
  
  
  # edit_dashboard_major_category_path	GET 	/dashboard/major_categories/:id/edit
  def edit
  end
  
  
  # dashboard_major_category_path	  PUT	 /dashboard/major_categories/:id
  def update
    @major_category.update(major_category_params)
    redirect_to dashboard_major_categories_path
  end
  
  
  # dashboard_major_category_path	  DELETE	/dashboard/major_categories/:id
  def destroy
    @major_category.destroy
    redirect_to dashboard_major_categories_path
  end
  
  
  
  private
    def major_category_params
      params.require(:major_category).permit(:name, :description)
    end

    def set_major_category
      @major_category = MajorCategory.find(params[:id])        
    end
end

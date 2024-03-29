class WebController < ApplicationController
  
  RECENTLY_PRODUCTS_PER_PAGE = 6
  RECOMMEND_PRODUCTS_PER_PAGE = 6
  
  def index
    @major_category_names = Category.major_categories
    @categories = Category.all
    @recently_products = Product.recently_products(RECENTLY_PRODUCTS_PER_PAGE)
      #Product.order(id: 'desc').with_attached_image.take(6)
    @recommend_products = Product.recommend_products(RECOMMEND_PRODUCTS_PER_PAGE)
      #Product.where(recommended_flag: true).order(id: 'asc').with_attached_image.take(6)
  end
  
    
end

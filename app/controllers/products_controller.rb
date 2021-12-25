class ProductsController < ApplicationController
  
  # GET  prefix:products  /products
  def index
    @products = Product.all
  end

  # GET  prefix:product  /products/1
  def show
    @product = Product.find(params[:id])
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
  end

  # GET  prefix:edit_product  /products/1/edit
  def edit
    @product = Product.find(params[:id])
    @categories = Category.all
  end

  # PATCH/PUT  prefix:product  /products/1
  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    redirect_to product_url(@product)
  end

  # DELETE  prefix:product  /products/1
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_url
  end
  
  private
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id)
    end
end

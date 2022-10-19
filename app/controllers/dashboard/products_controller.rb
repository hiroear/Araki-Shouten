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
  
  
  # CSV一括登録画面へ   GET  /dashboard/products/import/csv   dashboard/products#import
  def import
  end
  
  
  # CSV一括登録ボタンを押したら POSTでここに飛ぶ   POST	 /dashboard/products/import/csv   dashboard/products#import_csv
  def import_csv
    #⬇︎ フォームから params[:file]が届き、末尾の拡張子が.csvだったら
    if params[:file] && File.extname(params[:file].original_filename) == ".csv"
      # File.extname("ファイルパス") : extnameメソッドは Fileクラスのメソッドで、引数で指定したファイル名の.拡張子のみを文字列として返す
      # params[:パラメータ名].original_filename : フォームからアップロードされたファイル名を取得
      Product.import_csv(params[:file])
      flash[:success] = "CSVでの一括登録が成功しました!"
      redirect_to import_csv_dashboard_products_url
    else
      flash[:danger] = "CSVが追加されていません。CSVを追加してください。"
      redirect_to import_csv_dashboard_products_url
    end
  end
  
  
  # 雛形ファイルダウンロードボタンを押したら GETでここに飛ぶ   GET  /dashboard/products/import/csv_download
  def download_csv
    send_file(
      "#{Rails.root}/public/csv/products.csv",
      filename: "products.csv",   # ダウンロードするときに使用するファイル名を指定
      type: :csv                  # コンテントタイプを指定
    )
    # send_file(ファイルのパス, オプション={}) : 指定したパスに存在する画像やファイルを読み込みその内容をクライアントに送信
  end
  
  
  
  private
    def set_product
      @product = Product.find(params[:id])
    end
    
    def product_params
      params.require(:product).permit(:name, :description, :price, :recommended_flag, :carriage_flag, :category_id, :image)
    end
end

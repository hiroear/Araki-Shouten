class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews
  acts_as_likeable
  has_one_attached :image
  # has_one_attached : 各レコードとファイルを1対1の関係で紐づけるメソッド。:ファイル名には添付するファイルがわかる名前をつける
  # この記述で @product.imageのようにして添付されたファイルにアクセスできる
  # ファイル名(:image)はそのモデルが紐づいたフォームから送られるパラメーターのキーになる為 dashboard/products_controller ストロングパラメータに :imageを追加)
  
  
  extend DisplayList
  
  scope :on_category, -> (category) { where(category_id: category) }
  scope :sort_order, -> (order) { order(order) }
  
  # キーワード検索
  scope :search_product, -> (keyword) {
    where("name LIKE ? OR description LIKE ? OR price LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
  }
  
  scope :category_products, -> (category, page) { 
    on_category(category).
    display_list(page)
  }

  scope :sort_products, -> (sort_order, page) {
    on_category(sort_order[:sort_category]).
    sort_order(sort_order[:sort]).
    display_list(page)
  }

  scope :sort_list, -> { 
     {
       "並び替え" => "", 
       "価格の安い順" => "price asc",
       "価格の高い順" => "price desc", 
       "出品の古い順" => "created_at asc", 
       "出品の新しい順" => "created_at desc"
     }
   }
   
  
  scope :search_for_id_and_name, -> (keyword) {
    where('name LIKE ?', "%#{keyword}%").or(where('id LIKE ?', "%#{keyword}%"))
    # LIKE :あいまい検索
    # ? :プレースホルダー("%#{keyword}%"" がここに入る)
    # "%#{変数}%" :#{変数}内の文字列を部分一致で検索。必ずダブルクォートの中に入れる
  }
  
  scope :recently_products, -> (number) { order(created_at: 'desc').take(number) }
  
  scope :recommend_products, -> (number) { where(recommended_flag: true).take(number) }
  
  
  # Productsテーブルから product_idsに入っている(複数商品の) item_idと一致する product_idを探し、それぞれの商品の carriage_flagカラムの値(boolean)のみを配列で取得
  scope :check_products_carriage_list, -> (product_item_ids) { where(id: product_item_ids).pluck(:carriage_flag)}
  

  #該当のProductモデルに紐づくReviewモデルが必要なので Productモデルにメソッドを記述
  def reviews_new
    reviews.new
  end
  
  def reviews_with_id
    reviews.all.reviews_with_id  #Reviewモデルに reviews_with_idを定義。 reviews.all.where.not(product_id: nil)
  end


  def self.import_csv(file)
    new_products = []
    CSV.foreach(file.path, headers: true, encoding: "Shift_JIS:UTF-8") do |row|
      new_product = new   # Product.new
      new_product.attributes = row.to_hash.slice!(csv_attributes)
      new_products << new_product
    end
    
    if new_products.present?
      import new_products
      # import : activerecord-importを使って複数のレコードを一括保存
    end
  end

  
  
  private
    def self.csv_attributes
      [:name, :description, :price, :category_id, :recommended_flag, :carriage_flag]
    end

end

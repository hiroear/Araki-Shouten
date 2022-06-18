class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews
  
  #該当のProductモデルに紐づくReviewモデルが必要なので Productモデルにメソッドを記述
  def reviews_new
    reviews.new  #reviewモデルの新しいインスタンスをnew(作成)するメソッド
  end
  def reviews_with_id
    reviews.all.reviews_with_id  #reviews.all.where.not(product_id: nil)
  end
  
  
  # PER = 15
  # scope :display_list, -> (category, page) { 
  #   if category != "none"
  #     where(category_id: category).page(page).per(PER)
  #   else
  #     page(page).per(PER)
  #   end
  # }
  # Product.where(category_id: 1).page(2).per(15)
  #引数の(category)はparams[:category]又は"none"のいずれか。引数の(page)はparams[:page]で一定
  #categoryの値が"none"でない場合は where(category_id: category).page(page).per(PER)を返す( Product.where(category_id: params[:category]).page(params[:page]).per(15) )
  #categoryの値が"none"だった場合はpage(page).per(PER)を返す( Product.page(params[:page]).per(15) )
  
  
  # ⬇︎変更 scope :display_list, -> (page) { page(page).per(PER) }
  extend DisplayList
  
  scope :on_category, -> (category) { where(category_id: category) }
  scope :sort_order, -> (order) { order(order) }
  
  # scope :category_products, -> (category, page) { 
  #   where(category_id: category).page(page).per(PER)
  # }
  scope :category_products, -> (category, page) { 
    on_category(category).
    display_list(page)
  }
  
  #⬇︎ productsテーブルのpriceまたはupdated_atの値を使って商品を昇順・降順で並び替え
  # scope :sort_products, -> (sort_order, page) {
  #   where(category_id: sort_order[:sort_category]).order(sort_order[:sort]).
  #   page(page).per(PER)
  # }
  scope :sort_products, -> (sort_order, page) {
    on_category(sort_order[:sort_category]).
    sort_order(sort_order[:sort]).
    display_list(page)
  }
  # Product.where(category_id: sort_order[:sort_category]).order(sort_order[:sort])
  # Product.where(category_id: 1).order("price asc")
  
  #sort_listで生成されるハッシュがProductクラスにpriceカラムやupdate_atカラムがあるという事を
  #知っているのでProductクラスのscopeとして定義
  scope :sort_list, -> { 
     {
       "並び替え" => "", 
       "価格の安い順" => "price asc",
       "価格の高い順" => "price desc", 
       "出品の古い順" => "updated_at asc", 
       "出品の新しい順" => "updated_at desc"
     }
   }
   
  
  scope :search_for_id_and_name, -> (keyword) {
    where('name LIKE ?', "%#{keyword}%").or(where('id LIKE ?', "%#{keyword}%"))
    # LIKE :あいまい検索
    # ? :プレースホルダー("%#{keyword}%"" がここに入る)
    # "%キーワード%" :キーワードの文字を部分一致で検索。必ずダブルクォートの中に入れる 
  }
  

  acts_as_likeable
  # gem 'socializationによって、以下のメソッドがProductモデルで使えるようになった(引数のuserは変数、Userはモデル名)
  # product.liked_by?(user)  :そのユーザーが「いいね」をつけていればtrueを返し、つけていなければfalseを返す
  # product.likers(User)  :「いいね」をつけたユーザーを全て返す
  # ↓「いいね」をつけたユーザーの数をカウントし、整数を返す
  # def change
  #   add_column :#{Table_name}, :likers_count, :integer, :default => 0
  # end
  # product.likers_count
  
end

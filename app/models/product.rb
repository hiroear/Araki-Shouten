class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews
  
  #該当のProductモデルに紐づくReviewモデルが必要なので Productモデルにメソッドを記述
  def reviews_new
    reviews.new  #reviewモデルの新しいインスタンスをnew(作成)するメソッド
  end
  
  def reviews_with_id
    reviews.all.reviews_with_id  #Reviewモデルに scopeを定義せず reviews.all.where.not(product_id: nil) と書いてもOK
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
    # "%#{変数}%" :#{変数}内の文字列を部分一致で検索。必ずダブルクォートの中に入れる
  }
  
  scope :recently_products, -> (number) { order(created_at: 'desc').take(number) }
  # takeメソッド :オブジェクトの先頭から(number)までの要素を配列で返す(取得したい要素数を指定する)
  
  scope :recommend_products, -> (number) { where(recommended_flag: true).take(number) }
  
  
  scope :check_products_carriage_list, -> (product_ids) { where(id: product_ids).pluck(:carriage_flag)}
  # Productsテーブルから product_idsに入っている(複数の) item_idと一致する product_idを探し、その複数商品の carriage_flagカラムの値(boolean)のみ配列で取得
  

  acts_as_likeable
  # gem 'socializationによって、以下のメソッドがProductモデルで使えるようになった(引数のuserは変数、Userはモデル名)
  # product.liked_by?(user)  :そのユーザーが「いいね」をつけていればtrueを返し、つけていなければfalseを返す
  # product.likers(User)  :「いいね」をつけたユーザーを全て返す
  # ↓「いいね」をつけたユーザーの数をカウントし、整数を返す
  # def change
  #   add_column :#{Table_name}, :likers_count, :integer, :default => 0
  # end
  # product.likers_count
  
  has_one_attached :image     # has_one_attached :ファイル名
  # has_one_attached : 各レコードとファイルを1対1の関係で紐づけるメソッド。:ファイル名には、添付するファイルがわかる名前をつける。
  # has_one_attachedメソッドを書いたモデルの各レコードは、それぞれ1つのファイルを添付できる。
  # この記述で、モデル.ファイル名(@product.image)で、添付されたファイルにアクセスできるようになる。
  # ファイル名(image)は、そのモデルが紐づいたフォームから送られるパラメーターのキーになる (dashboard/products_controller ストロングパラメータに , :image のキーを追加)。


  def self.import_csv(file)
    new_products = []
    update_products = []
    CSV.foreach(file.path, headers: true, encoding: "Shift_JIS:UTF-8") do |row|
      # CSV.foreach ▶︎ CSVファイルの内容を 1行(レコード)づつ取り出す　(例:[ "abc","abc説明", "200","false","true"],[ "def","def説明", "400","true","true"...)
      # file.path ▶︎ ファイルのパスを指定 / headers: true ▶︎ row[1] でなく row[:name]のように扱うことが可能になる
      # encoding ▶︎ Shift_JIS形式の CSVを1行ずつ UTF-8に変換しながら読み込み（メモリに優しい)
      
      row_to_hash = row.to_hash   # CSVデータの一行をハッシュ {キー =>"値"} に整形?
      # byebug
      
      #⬇︎ IDが見つかればレコードを呼び出し productの中身を更新する為の update_products[] を生成
      # (別の書き方 : product = find(id: row_to_hash["id"]) || new)
      if row_to_hash[:id].present?  # if exists?(id: row_to_hash["id"])
        update_product = find(id: row_to_hash[:id])  # row_to_hash[:id] と一致する product_idを探し update_productに代入
          #update_product = find(row_to_hash["id"]) row_to_hash配列のキーが文字列のため "id"として取り出す必要がある?
        update_product.attributes = row.to_hash.slice!(csv_attributes)
          # attributesメソッド : 特定の attribute(カラム)を変更(更新)する (オブジェクトの変更のみ。DBには保存されない)
          # slice!メソッド : 配列や文字列から指定した要素[:name, :description, :price,・・・]を取り出す
        update_products << update_product   # << = push  /  update_products.push(update_product)
          # update_products[{ :id => 3, :name => "abc", :description => "abc説明", :price => 500, :recommended_flag => false, :carriage_flag => false }]
      
      #⬇︎ IDが見つからなければ新しくインスタンスを作成し指定の要素の new_products[] を生成
      else
        new_product = new   # Product.new
        new_product.attributes = row.to_hash.slice!(csv_attributes)
        new_products << new_product
          # new_products[{ :name => "abc", :description => "abc説明", :price => 500,... }]
      end
    end
    
    if update_products.present?
      import update_products, on_duplicate_key_update: csv_attributes
      # on_duplicate_key_update: バルクインサート(あるテーブルに複数のレコードを一括保存)する際、新規レコードは作成、主キー/ユニークキー制約に引っかかったレコードは、そのレコードの指定したカラムの値だけ更新(Upsert)してくれる
    elsif new_products.present?
      import new_products
      # import : activerecord-importを使って複数のレコードを一括保存する
    end
  end

  
  
  private
    def self.csv_attributes
      [:name, :description, :price, :recommended_flag, :carriage_flag]
    end

end

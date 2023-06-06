# カートを1つのデータとしてカウントし、DBに保存するモデル

class ShoppingCart < ApplicationRecord
  acts_as_shopping_cart


  scope :set_user_cart, -> (user) { user_cart = where(user_id: user.id, buy_flag: false)&.last
                              user_cart.nil? ? ShoppingCart.create(user_id: user.id)
                                             : user_cart }
  
  def tax_pct
    0
  end
  
  
  scope :sort_list, -> {{ '日別': 'daily', '月別': 'month'}}
  scope :bought_carts, -> { where(buy_flag: true) }     #購入済みのカート情報
  
  # sqlite用  月単位 /日単位の売上の重複データを除いたカート一覧を降順・配列で取得
  scope :bought_months_sqlite, -> {
    bought_carts                                        # 購入済みのカート情報を
    .order(updated_at: :desc)                           # 更新日の降順に並び替え
    .group("strftime('%Y-%m', updated_at, '+09:00')")   # 更新日時(UTCから9時間足した日本時間)を strftimeメソッドで'20○○年○月'に書式化・文字列に変換 ▶ それを groupで重複を除く
    .pluck(:updated_at)                                 # pluck：引数の値を配列で返す
    # ["2023-5","2023-6"]
  }
  scope :bought_days_sqlite, -> {
    bought_carts
    .order(updated_at: :desc)
    .group("strftime('%Y-%m-%d', updated_at, '+09:00')")
    .pluck(:updated_at)
  }
  
  # pg用  月単位 /日単位の売上の重複データを除いたカート一覧を降順・配列で取得
  scope :bought_months_pg, -> {
    bought_carts
    .pluck("distinct(date_trunc('month', updated_at + '9 hours'))").map{ |m| m.in_time_zone('Asia/Tokyo') }.reverse
      # 更新日時(UTCから9時間足した日本時間)を月単位で切り捨て(date_trunc) ▶︎ それをdistinctで重複を防ぎ ▶ それを pluckで囲って配列に。
      # 作った配列をさらに in_time_zoneで Railsのタイムゾーンに直し mapで新しい配列に。
      # reverse：要素を逆順(降順)に並べた新しい配列を生成して返す
  }
  scope :bought_days_pg, -> {
    bought_carts
    .pluck("distinct(date_trunc('day', updated_at + '9 hours'))")
    .map{ |d| d.in_time_zone('Asia/Tokyo') }.reverse
  }
  
  
  # それぞれの月/日に購入された全てのカートデータ一覧
  scope :bought_carts_by_month, -> (month) { bought_carts.where(updated_at: month.all_month) }
    # 全ての売上カートデータの内それぞれの月毎の全カートを取得 (引数にupdated_atカラムが含まれているカートのみ)
    # all_month: その月の期間の全範囲のデータを取得 (例：9月の1～30日)
  scope :bought_carts_by_day, -> (day) { bought_carts.where(updated_at: day.all_day) }
    # all_day: 現時刻を含むその日1日の全範囲のデータを取得 (00:00:00から23:59:59までの全データ)
  
  
  # ダッシュボード  受注一覧  注文番号検索
  scope :search_carts_by_ids, -> (ids) { where("cast(id as text) LIKE ?", "%#{ids}%") }
  scope :search_bought_carts_by_ids, -> (ids) { bought_carts.search_carts_by_ids(ids) }
  # where(buy_flag: true).where("id LIKE ?", "%#{ids}%")
  
  # ダッシュボード  受注一覧  注文者名検索
  scope :search_bought_carts_by_user, -> (user) { bought_carts.where(user_id: user) }
  
  
  #︎ 月単位売上データ(カート)の [{配列}] を返すクラスメソッド (メソッド名の先頭に selfをつけることでクラスメソッドになる)
  def self.get_monthly_sales
    if Rails.env.production?         # 本番環境
      months = bought_months_pg      # pg用  月単位の重複データを除いた売上カート一覧を降順・配列で取得
    else                             # 開発環境
      months = bought_months_sqlite  # sqlite用  月単位の重複データを除いた売上カート一覧を降順・配列で取得
    end
    
    array = Array.new(months.count) { Hash.new }
      # [{キー：値, キー...}] のような中が連想配列の空の配列を monthsの数だけ生成
      # Array.new：(要素数)分の [配列] を定義   /   {Hash.new}：{連想配列} を定義

    months.each_with_index do |month, i|
      #↓︎ monthに入っているそれぞれの月毎の売上カートデータ全一覧を取得
      monthly_sales = bought_carts_by_month(month)
      
      #↓ 月毎のカートの売上合計
      total = 0
      monthly_sales.each do |monthly_sale|
        total += monthly_sale.total.fractional / 100
        # monthly_sale.total : 例) 売上100円のカートの場合  出力結果 ▶︎ 100.00 (acts_as_shopping_cartの仕様上米ドル表示になる)
        # monthly_sale.total.fractional : 小数点を無くす為 fractionalをつけると   結果 ▶︎ 10000
        # monthly_sale.total.fractional / 100 : 小数点を無くしただけでは金額が合わないので100で割る   結果 ▶︎ 100
      end
      
      # array[i]番目に [:period]というキーを作り値をキーに代入
      array[i][:period] = month.strftime("%Y-%m")          # 年月
      array[i][:total] = total                             # 金額
      array[i][:count] = monthly_sales.count               # 件数
      array[i][:average] = total / monthly_sales.count     # 平均単価
    end
    
    return array    #最後に上で生成した配列を明示的に返す
    #︎ [{:period=>"2023-05", :total=>9, :count=>1, :average=>9}, {:period=>...]
  end
  
  
  # ︎日単位売上データ(カート)の [{配列}] を返すクラスメソッド
  def self.get_daily_sales
    if Rails.env.production?
      days = bought_days_pg
    else
      days = bought_days_sqlite
    end
    
    array = Array.new(days.count) { Hash.new }
    
    days.each_with_index do |day, i|
      daily_sales = bought_carts_by_day(day)
      
      total = 0
      daily_sales.each do |daily_sale|
        total += daily_sale.total.fractional / 100
      end
      
      array[i][:period] = day.strftime("%Y-%m-%d")   # 年月日
      array[i][:total] = total
      array[i][:count] = daily_sales.count
      array[i][:average] = total / daily_sales.count
    end
    
    return array
  end
  
  
  
  CARRIAGE = 800     #送料金額
  FREE_SHIPPING = 0
  
  # 送料の有無を判定
  # カート内の商品の carriage_flagに1つでも trueの商品が含まれていれば合計金額に送料を加算する処理
  def shipping_cost
    product_item_ids = ShoppingCartItem.user_cart_item_ids(self.id)
      # ShoppingCartItem.where(owner_id: ShoppingCart.id).pluck(:item_id)
      # ShoppingCartItemsテーブルのowner_idと ShoppingCart.id が一致するカートを探し、そのカート内の item_idカラムの値のみ配列で取得(商品が複数の場合の為)
    products_carriage_list = Product.check_products_carriage_list(product_item_ids)
      # Product.where(id: product_item_ids).pluck(:carriage_flag)
      # Productsテーブルから product_item_idsに入っている(複数商品の)item_idと一致する product_idを探し、それぞれの商品の carriage_flagカラムの値(boolean)のみを配列で取得
    products_carriage_list.include?(true) ? Money.new(CARRIAGE * 100)
                                          : Money.new(FREE_SHIPPING)
      # array.include?...配列に使うメソッド boolean型。配列が引数の (値) と == で等しい要素を持つ時 trueを返す
      # acts_as_shopping_cartのルールで shipping_costメソッドに Moneyオブジェクトの値を定義すれば送料を設定する機能が予めついている
      # ↑元々 USDを想定して作られているgemで、Money.newの引数にはドルの 1/100を渡すルールになっている為、日本円 800円に 100倍した値を引数として渡す
  end
  
end

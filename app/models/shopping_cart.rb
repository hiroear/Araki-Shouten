# カートを1つのデータとしてカウント、DBに保存するモデル

class ShoppingCart < ApplicationRecord
  acts_as_shopping_cart


  scope :set_user_cart, -> (user) { user_cart = where(user_id: user.id, buy_flag: false)&.last
                              user_cart.nil? ? ShoppingCart.create(user_id: user.id)
                                             : user_cart }
  
  # tax_pctメソッドは、acts_as_shopping_cartで用意されている消費税を計算するメソッド
  # 本アプリは税込表示になっていて 0としたほうが都合がよいため、オーバーライドしている
  def tax_pct
    0
  end
  
  
  scope :bought_carts, -> { where(buy_flag: true) }   # shopping_cartsテーブル buy_flagカラムが trueのデータ
  
  #⬇︎ sqlite用の月別 /日別売上の重複データを除いた一覧を配列で取得する scope (降順)
  scope :bought_months_sqlite, -> {
    bought_carts
    .order(updated_at: :desc)                           # 更新日の降順に並び替え
    .group("strftime('%Y-%m', updated_at, '+09:00')")   # UTC時間から9時間足した更新日時を '20○○年○月'に書式化 ▶︎ それをgroup化
    .pluck(:updated_at)                    # pluck：特定のカラムの値だけ取得。引数に指定したカラムの値を配列で返す
  }
  scope :bought_days_sqlite, -> {
    bought_carts
    .order(updated_at: :desc)
    .group("strftime('%Y-%m-%d', updated_at, '+09:00')")
    .pluck(:updated_at)
  }
  
    #⬇︎ pg用の月別 /日別売上の重複データを除いた一覧を配列で取得する scope (降順)
  scope :bought_months_pg, -> {
    bought_carts                       #⬇︎ UTC時間から 9時間足した更新日時を月単位で切り捨て ▶︎ それを distinct化
    .pluck("distinct(date_trunc('month', updated_at + '9 hours'))")
    .map{ |m| m.in_time_zone('Asia/Tokyo') }.reverse         # in_time_zone：mを日本時間に変換
  }
  scope :bought_days_pg, -> {
    bought_carts
    .pluck("distinct(date_trunc('day', updated_at + '9 hours'))")
    .map{ |d| d.in_time_zone('Asia/Tokyo') }.reverse         # reverse：要素を逆順に並べた新しい配列を生成して返す
  }
  
  
  # ⬇︎指定の月 / 日に購入された全てのカートデータの一覧を取得するスコープ
  scope :search_bought_carts_by_month, -> (month) { bought_carts.where(updated_at: month.all_month) }
  scope :search_bought_carts_by_day, -> (day) { bought_carts.where(updated_at: day.all_day) }
    # shopping_cartsテーブル buy_flagカラムが true、かつ updated_atカラムが引数に指定した月の全データ(カート)を取得
    # all_month：その日を含む月の全範囲のデータを取得 (例：9月の1～30日)
    # all_day：今日の日付で、00:00:00から23:59:59までの全データを取得
  
  scope :sort_list, -> { {"日別": "daily", "月別": "month"} }
  
  
  # ⬇︎月別売上データの [{配列}] を返すクラスメソッド (メソッド名の先頭に selfをつけることでクラスメソッドになる)
  def self.get_monthly_sales
    if Rails.env.production?         # 本番環境だったら
      months = bought_months_pg      # pg(PostgreSQL)用の月別売上の重複データを除いた一覧を配列で取得(降順)
    else                             # 開発環境だったら
      months = bought_months_sqlite  # sqlite用の月別売上の重複データを除いた一覧を配列で取得(降順)
    end
    
    array = Array.new(months.count) { Hash.new }
    # 中がハッシュの [{キー：値,キー：値,キー：値...}] のような新しい空の配列を monthsの数だけ生成
    # Array.new： (要素数)分の [配列] を定義
    # {Hash.new}： {中にハッシュが入っている配列} を定義

    months.each_with_index do |month, i|
      # each_with_index : eachループで回しつつ其々のデータに番号を振りたい時に使う
      monthly_sales = search_bought_carts_by_month(month)     #指定月の全範囲の全ての購入カートデータ一覧を取得
      
      total = 0
      monthly_sales.each do |monthly_sale|
        total += monthly_sale.total.fractional / 100   # monthly_saleに入っているカートの売上合計を出す = total
        # monthly_sale.total : 例) 売上100円 のカートの場合  出力結果 ▶︎ 100.00 (acts_as_shopping_cartの仕様上米ドル表示になる)
        # monthly_sale.total.fractional : 小数点部分を無くす為 fractional を実行   結果 ▶︎ 10000
        # monthly_sale.total.fractional / 100 : 小数点を無くしただけでは金額が合わないので /100   結果 ▶︎ 100
      end
      
      # array[i]番目に [:period] というキーを作って = 以降の値をキーに代入
      array[i][:period] = month.strftime("%Y-%m")          # 年月日
      array[i][:total] = total                             # 金額
      array[i][:count] = monthly_sales.count               # 件数
      array[i][:average] = total / monthly_sales.count     # 平均単価
    end
    
    return array    #生成した配列を返す
    #例 ▶︎ [{:period=>"2022-07", :total=>9, :count=>1, :average=>9}, {:period=>"2022-06", :total=>10, :count=>2, :average=>5}, {:period=>"2022-04", :total=>41, :count=>1, :average=>41}...]
  end
  
  
  # ⬇︎日別売上データの [{配列}] を返すクラスメソッド
  def self.get_daily_sales
    if Rails.env.production?
      days = bought_days_pg
    else
      days = bought_days_sqlite
    end
    
    array = Array.new(days.count) { Hash.new }
    
    days.each_with_index do |day, i|
      daily_sales = search_bought_carts_by_day(day)
      
      total = 0
      daily_sales.each do |daily_sale|
        total += daily_sale.total.fractional / 100
      end
      
      array[i][:period] = day.strftime("%Y-%m-%d")
      array[i][:total] = total
      array[i][:count] = daily_sales.count
      array[i][:average] = total / daily_sales.count
    end
    
    return array
  end
  
  
  CARRIAGE = 800      #送料金額
  FREE_SHIPPING = 0
  
  def shipping_cost
    product_ids = ShoppingCartItem.user_cart_item_ids(self.id)  #self省略可
      # インスタンスメソッド内で selfをつけるとインスタンスが持つ情報(今回はShoppingCart.id)にアクセスできる
      # ShoppingCartItem.where(owner_id: self.id).pluck(:item_id)
      # ShoppingCartItemsテーブルから self.idと一致するカートを探し、その中の(複数の) item_idカラムの値のみ配列で取得
    products_carriage_list = Product.check_products_carriage_list(product_ids)
      # Product.where(id: product_ids).pluck(:carriage_flag)
      # Productsテーブルから idカラムが product_idsと一致する(複数)データを探し その複数商品の carriage_flagカラムの値のみ配列で取得
    products_carriage_list.include?(true) ? Money.new(CARRIAGE * 100)
                                          : Money.new(FREE_SHIPPING)
      # カート内商品の carriage_flagの値の中に 1つでもtrueの商品が含まれていれば合計金額に送料を加算する処理
      # acts_as_shopping_cartは USDを想定した gemで、Money.newの引数はドルの100分の1であるセント単位で整数を渡すルール。今回は定数 CARRIAGEに日本円の金額を代入、その金額を100倍した値を引数として渡した。
      # array.include?...配列要素に使うメソッド。boolean型。配列が(値)と == で等しい場合 trueを返す。
  end
  
end

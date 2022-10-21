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
  
  
  scope :sort_list, -> {{ '切り替え': '', '月別': 'month', '日別': 'daily'}}   #セレクトボックスの内容。パラメータ
  scope :bought_carts, -> { where(buy_flag: true) }   #購入済みのカート情報
  
  #⬇︎ sqlite用  月単位 /日単位の売上の重複データを除いたカート一覧を降順・配列で取得
  scope :bought_months_sqlite, -> {
    bought_carts                                        # 購入済みのカート情報を
    .order(updated_at: :desc)                           # 更新日の降順に並び替え
    .group("strftime('%Y-%m', updated_at, '+09:00')")   # 更新日時(UTCから9時間足した日本時間)を strftimeメソッドで'20○○年○月'に書式化・文字列に変換 ▶ それを groupで重複を除く
    .pluck(:updated_at)                                 # pluck：引数に指定したカラムの値を配列で返す (特定のカラムの値だけ取得したい場合に使う)
    # ["2022-5","2022-10"]
  }
  scope :bought_days_sqlite, -> {
    bought_carts
    .order(updated_at: :desc)
    .group("strftime('%Y-%m-%d', updated_at, '+09:00')")
    .pluck(:updated_at)
  }
  
  #⬇︎ pg用  月単位 /日単位の売上の重複データを除いたカート一覧を降順・配列で取得
  scope :bought_months_pg, -> {
    bought_carts    # 購入済みのカート情報を
    .pluck("distinct(date_trunc('month', updated_at + '9 hours'))").map{ |m| m.in_time_zone('Asia/Tokyo') }.reverse
      # 更新日時(UTCから9時間足した日本時間)を月単位で切り捨て ▶︎ それをdistinctで重複レコードを1つにまとめる ▶pluckで囲って指定した値を配列に
      # 上で作った配列をさらに mapで新しい配列にする(in_time_zone：|m|を日本時間に変換)
      # .reverse：これまでの要素を逆順(降順)に並べた新しい配列を生成して返す
  }
  scope :bought_days_pg, -> {
    bought_carts
    .pluck("distinct(date_trunc('day', updated_at + '9 hours'))")
    .map{ |d| d.in_time_zone('Asia/Tokyo') }.reverse
  }
  
  
  # ⬇︎それぞれの月/日に購入された全てのカートデータの一覧を取得
  scope :search_bought_carts_by_month, -> (month) { bought_carts.where(updated_at: month.all_month) }
    # 全ての売上カートデータの内 updated_atカラムが、引数に含まれているカート情報の月の全カートデータを取得
    # all_month メソッド...その月の期間の全範囲のデータを取得 (例：9月の1～30日)
  scope :search_bought_carts_by_day, -> (day) { bought_carts.where(updated_at: day.all_day) }
    # all_dayメソッド...現時刻を含むその日1日の全範囲のデータを取得 (00:00:00から23:59:59までの全データ)
  
  
  # ダッシュボード  受注一覧  注文番号検索
  scope :search_carts_by_ids, -> (ids) { where("id LIKE ?", "%#{ids}%") }
  scope :search_bought_carts_by_ids, -> (ids) { bought_carts.search_carts_by_ids(ids) }
  # where(buy_flag: true).where("id LIKE ?", "%#{ids}%")
  
  
  scope :search_bought_carts_by_user, -> (user) { bought_carts.where(user_id: user) }
  
  # ⬇︎月単位売上データ(カート)の [{配列}] を返すクラスメソッド (メソッド名の先頭に selfをつけることでクラスメソッドになる)
  def self.get_monthly_sales
    if Rails.env.production?         # 本番環境の場合
      months = bought_months_pg      # pg用  月単位の重複データを除いた売上カート一覧を降順・配列で取得
    else                             # 開発環境の場合
      months = bought_months_sqlite  # sqlite用  月単位の重複データを除いた売上カート一覧を降順・配列で取得
    end
    
    array = Array.new(months.count) { Hash.new }
    # [{キー：値, キー：値, キー：値...}] のような中がハッシュの新しい空の配列を monthsの数だけ生成
      # Array.new：(要素数)分の [配列] を定義   /   {Hash.new}：{連想配列} を定義

    months.each_with_index do |month, i|
      #⬇︎ monthに入っているそれぞれの月毎の全ての売上カートデータ一覧を取得
      monthly_sales = search_bought_carts_by_month(month)
      
      total = 0
      monthly_sales.each do |monthly_sale|
        #⬇︎ monthly_saleに入っているカートの売上合計を出す
        total += monthly_sale.total.fractional / 100
        # monthly_sale.total : 例) 売上100円 のカートの場合  出力結果 ▶︎ 100.00 (acts_as_shopping_cartの仕様上米ドル表示になる)
        # monthly_sale.total.fractional : 小数点部分を無くす為 fractional を実行   結果 ▶︎ 10000
        # monthly_sale.total.fractional / 100 : 小数点を無くしただけでは金額が合わないので /100   結果 ▶︎ 100
      end
      
      # array[i]番目に [:period] というキーを作って = 以降の値をキーに代入
      array[i][:period] = month.strftime("%Y-%m")          # 年月
      array[i][:total] = total                             # 金額
      array[i][:count] = monthly_sales.count               # 件数
      array[i][:average] = total / monthly_sales.count     # 平均単価
    end
    
    return array    #最後に、上で生成した配列を返す
    #例 ▶︎ [{:period=>"2022-07", :total=>9, :count=>1, :average=>9}, {:period=>"2022-06", :total=>10, :count=>2, :average=>5}, {:period=>"2022-04", :total=>41, :count=>1, :average=>41}...]
  end
  
  
  # ⬇︎︎日単位売上データ(カート)の [{配列}] を返すクラスメソッド
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
      
      array[i][:period] = day.strftime("%Y-%m-%d")   # 年月日
      array[i][:total] = total
      array[i][:count] = daily_sales.count
      array[i][:average] = total / daily_sales.count
    end
    
    return array
  end
  
  
  
  CARRIAGE = 80000     #送料金額
  FREE_SHIPPING = 0
  
  # 送料の有無を判定
  def shipping_cost
    product_ids = ShoppingCartItem.user_cart_item_ids(self.id)  #self省略可
      # ShoppingCartItem.where(owner_id: self.id).pluck(:item_id)
      # ShoppingCartItemsテーブルの owner_idと ShoppingCart_id が一致するカートを探し、そのカート内の(複数の) item_idカラムの値のみ配列で取得
      # インスタンスメソッド内で selfをつけるとインスタンスが持つ情報(今回は ShoppingCart_id) にアクセスする。※self省略可
    products_carriage_list = Product.check_products_carriage_list(product_ids)
      # Product.where(id: product_ids).pluck(:carriage_flag)
      # Productsテーブルから product_ids内の(複数の) item_idと一致する product_idを探し、その(複数)商品の carriage_flagカラムの値(boolean)のみ配列で取得
    products_carriage_list.include?(true) ? Money.new(CARRIAGE)
                                          : Money.new(FREE_SHIPPING)
      # カート内の商品の carriage_flagの値に 1つでもtrueの商品が含まれていれば合計金額に送料を加算する処理
      # acts_as_shopping_cartでは shipping_costメソッドにMoneyオブジェクトの値を定義すれば送料を設定する機能がついている
      # acts_as_shopping_cartのメソッド Money.newの引数にはセント単位(ドルの100分の1) で整数を渡すルールがある。今回は定数 CARRIAGEに日本円の金額を代入後その金額を100倍した値を引数として渡した
      # array.include?...配列要素に使うメソッド。boolean型。配列が引数の (値) と == で等しい要素を持つ時 trueを返す
  end
  
end

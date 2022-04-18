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
  
end

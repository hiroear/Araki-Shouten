# 商品が入っているカートの内容をDBに保存するモデル

class ShoppingCartItem < ApplicationRecord
  acts_as_shopping_cart_item
  
  scope :user_cart_items, -> (user_shoppingcart) { where(owner_id: user_shoppingcart) }
  
  scope :user_cart_item_ids, -> (user_shoppingcart) { where(owner_id: user_shoppingcart).pluck(:item_id) }
    #ShoppingCartsテーブルの idから owner_idが一致するカートを探し、そのカート内の(複数の) item_idカラムの値のみ配列で取得
end

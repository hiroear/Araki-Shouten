# 商品が入っているカートの内容を1つのデータとしてカウント、DBに保存するテーブル?

class CreateShoppingCartItems < ActiveRecord::Migration[5.2]
  def change
    create_table :shopping_cart_items do |t|
      t.shopping_cart_item_fields

      t.timestamps
    end
  end
end

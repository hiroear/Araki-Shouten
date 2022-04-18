# shopping_cart_itemsテーブルの price_currencyカラム のdefaultを USD ▶︎ JPYに変更 (既存カラムの変更)
# up / downメソッドによって、マイグレーション適用前と適用後を明示的にできる。つまり、ロールバックすることができる

class ChangePriceCurrencyToShoppingCartItems < ActiveRecord::Migration[5.2]
  def up
    change_column :shopping_cart_items, :price_currency, :string, default: "JPY", null: false
  end

  def down
    change_column :shopping_cart_items, :price_currency, :string, default: "USD", null: false
  end
end

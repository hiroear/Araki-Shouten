class RemoveShoppingCartItemIdFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :products, :shopping_cart_items
    remove_reference :products, :shopping_cart_item_id, index: true
  end
end

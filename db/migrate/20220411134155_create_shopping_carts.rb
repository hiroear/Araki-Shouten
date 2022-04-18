# カートを1つのデータとしてカウント、DBに保存するテーブル

class CreateShoppingCarts < ActiveRecord::Migration[5.2]
  def change
    create_table :shopping_carts do |t|
      t.boolean :buy_flag, null: false, default: false  #そのカートが注文確定済みか否かを判別するカラム
      t.references :user, foreign_key: true  #どのユーザーのカートか判別できるようにuser_idを外部キーで持ってくる
      
      t.timestamps
    end
  end
end

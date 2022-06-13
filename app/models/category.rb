class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  #dependent: :destroy...カテゴリを削除する際 そのカテゴリに紐づいている商品も同時に削除
  
  scope :major_categories, -> { pluck(:major_category_name).uniq }
  #pluck(:major_category_name): 全てのカテゴリデータの中からmajor_category_nameのカラムのみを取得。
  #uniqメソッド: 重複するデータを削除
  #scopeを使ってメソッド定義することで、事前にscope内で指定した実行してほしいクエリを渡すことができる
  
  # scope :request_category, -> (category) {
  #   if category != "none"
  #     find(category.to_i)
  #   else
  #     ""
  #   end
  # }
  scope :request_category, -> (category) { find(category.to_i) }
  
  extend DisplayList
end

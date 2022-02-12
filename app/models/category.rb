class Category < ApplicationRecord
  has_many :products
  
  scope :major_categories, -> { pluck(:major_category_name).uniq }
  #pluck(:major_category_name): 全てのカテゴリデータの中からmajor_category_nameのカラムのみを取得。
  #uniqメソッド: 重複するデータを削除
  #scopeを使ってメソッド定義することで、事前にscope内で指定した実行してほしいクエリを渡すことができる
  
  scope :request_category, -> (category) {
    if category != "none"
      find(category.to_i)
    else
      ""
    end
  }
end

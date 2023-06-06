class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  belongs_to :major_category
  
  scope :major_categories, -> { pluck(:major_category_name).uniq }
  #pluck(:major_category_name): categoriesテーブル内からmajor_category_nameカラムのみ取得
  #uniq: 重複するデータを削除
  
  # scope :major_category_ids, -> { pluck(:major_category_id).uniq }
  # scope :major_category_names, -> { major_category_ids.map{ |item| MajorCategory.find(item).name }}
  
  scope :request_category, -> (category) { find(category.to_i) }
  
  extend DisplayList
end

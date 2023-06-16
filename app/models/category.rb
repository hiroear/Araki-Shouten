class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  belongs_to :major_category
  
  extend DisplayList
  
  scope :major_categories, -> { pluck(:major_category_name).uniq }
  #pluck(:major_category_name): categoriesテーブル内からmajor_category_nameカラムのみ取得
  #uniq: 重複するデータを削除
  
  # scope :major_category_ids, -> { pluck(:major_category_id).uniq }
  # scope :major_category_names, -> { major_category_ids.map{ |id| MajorCategory.find(id).name }}
  
  scope :request_category, -> (category) { find(category.to_i) }
  
  
  # categoriesテーブルのmajor_category_idカラムの値と params[:major_category_id] が一致するデータを探し(複数)、その category_idカラムの値のみ配列で取得
  scope :find_category_ids, -> (major_category_id) { where(major_category_id: major_category_id).pluck(:id) } #[1, 2, 3, 4, 5 ...] 
  
  
end

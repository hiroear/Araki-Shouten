class MajorCategory < ApplicationRecord
  has_many :categories
  
  extend DisplayList
  
  # scope :major_category_name_and_id, -> { all.pluck(:name, :id) }
  # モデル名.pluck(:カラム名) :pluckメソッドは、引数に指定したカラムの値を配列で返すメソッド
  # pluckメソッドは、全てのデータではなく特定のカラムの値だけ取得したい場合に使う
end

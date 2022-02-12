class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews
  
  def reviews_new
    reviews.new #reviewをcreateする時のnewするメソッド
  end
  
  acts_as_likeable
  # ⬇︎gem 'socializationによって、以下のメソッドがProductモデルで使えるようになった(引数のuserは変数、Userはモデル名)
  # product.liked_by?(user)  :そのユーザーが「いいね」をつけていればtrueを返し、つけていなければfalseを返す
  # product.likers(User)  :「いいね」をつけたユーザーを全て返す
  # ↓「いいね」をつけたユーザーの数をカウントし、整数を返す
  # def change
  #   add_column :#{Table_name}, :likers_count, :integer, :default => 0
  # end
  # product.likers_count
  
end

class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews
  
  def reviews_new
    reviews.new #reviewをcreateする時のnewするメソッド
  end
  
  
  PER = 15
  #⬆︎コードがマジックナンバーばかりになってしまうとシステム改修の際苦労する為、極力マジックナンバーを避ける為定義する
  scope :display_list, -> (category, page) { 
    if category != "none"
      where(category_id: category).page(page).per(PER)
    else
      page(page).per(PER)
    end
  }
  #引数の(category)はparams[:category]又は"none"のいずれか。引数の(page)はparams[:page]で一定
  #categoryの値が"none"でない場合は where(category_id: category).page(page).per(PER)を返す( Product.where(category_id: params[:category]).page(params[:page]).per(15) )
  # 一方で、categoryの値が"none"だった場合はpage(page).per(PER)を返す( Product.page(params[:page]).per(15) )
  
  
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

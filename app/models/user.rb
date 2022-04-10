class User < ApplicationRecord
  has_many :reviews
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable #←メール送信機能実装のため confirmableを追加
         
  acts_as_liker
  # ⬇︎gem 'socializationによって、以下のメソッドがUserモデルで使えるようになった(引数のproductは変数)
  # user.like!(product)  :商品に対して「いいね」をつける
  # user.unlike!(product)  :商品に対する「いいね」を解除する
  # user.toggle_like!(product)  :商品に対する「いいね」の状態を現在の状態から逆にする
  # user.likes?(product)  :商品に対して「いいね」をつけていればtrueを返し、つけていなければfalseを返す
  # ↓「いいね」の数をカウントし、整数を返す
  # def change
  #   add_column :#{Table_name}, :likees_count, :integer, :default => 0
  # end
  # user.likees_count
  
  
  # ユーザーから送信されたpasswordとpassword_confirmationが一致するかどうかを確認し
  # 一致する場合のみパスワードを暗号化してデータベースに保存
  def update_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
 
    result = update(params, *options)
    clean_up_passwords
    result
  end
  
end

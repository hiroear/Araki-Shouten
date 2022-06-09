class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :validatable
  
  # deviseのログイン機能とバリデーション機能だけを有効にする
  devise :database_authenticatable, :rememberable, :validatable
end

class Review < ApplicationRecord
    belongs_to :product
    belongs_to :user
    
    def save_review(review, review_params)
      review.content = review_params[:content]
      review.user_id = review_params[:user_id]
      review.product_id = review_params[:product_id]
      review.score = review_params[:score]
      save
    end
    
    scope :star_repeat_select, -> {
      {
        "★★★★★" => 5,
        "★★★★" => 4,
        "★★★" => 3,
        "★★" => 2,
        "★" => 1
      }
    }
    
    # idを持っているReviewオブジェクトのみ取得するスコープを定義 (product_idが nilじゃないものだけを取得)
    scope :reviews_with_id, -> { where.not(product_id: nil) }
end

# @review.save_review(,)

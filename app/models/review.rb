class Review < ApplicationRecord
    belongs_to :product
    belongs_to :user
    
    def save_review(review, araki)
      review.content = araki[:content]
      review.user_id = araki[:user_id]
      review.product_id = araki[:product_id]
      save
    end
    
    # def matushsita(r,z)
    #   x = r + z
    #   return x
    # end
end

# @review.save_review(,)

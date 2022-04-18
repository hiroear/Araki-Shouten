class ReviewsController < ApplicationController
  def create
    product = Product.find(params[:product_id]) #レビューが投稿された商品データを取得
    review = product.reviews_new                #Productモデルに記述のreviews_newメソッド (reviewをcreateするnewメソッド)
    review.save_review(review, review_params)   #save_reviewメソッド。引数にストロングパラメータを渡す
    redirect_to product_url(product)
  end
  
  
  private
  
    def review_params
      params.require(:review).permit(:content).
             merge(user_id: current_user.id, product_id: params[:product_id])
    end
    #deviseで用意されているcurrent_userメソッドで、ユーザーのidをパラメータに加える
    
end

class ReviewsController < ApplicationController
  def create
    product = Product.find(params[:product_id])  #レビューが投稿された該当商品データを取得
    review = product.reviews_new                 #該当の商品に関する新しいreviewインスタンスを生成
    review.save_review(review, review_params)    #save_review :引数に新しいインスタンスとreview_paramsを渡しDBに保存
    redirect_to product_url(product)
  end
  
  
  private
  
    def review_params
      params.require(:review).permit(:content, :score).
             merge(user_id: current_user.id, product_id: params[:product_id])
    end
    # merge :取得したパラメータに追加する。ログインユーザーidと該当のproduct_id を追加
    
end

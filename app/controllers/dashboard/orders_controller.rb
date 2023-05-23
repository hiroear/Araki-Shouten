# ダッシュボード / 受注一覧
class Dashboard::OrdersController < ApplicationController
  before_action :authenticate_admin!
  layout "dashboard/dashboard"

  def index
    if params[:code].present?
      @code = params[:code]
      @orders = ShoppingCart.search_bought_carts_by_ids(@code).order(updated_at: "desc").page(params[:page]).per(15)
      # ShoppingCart.where(buy_flag: true).where("params[:code] LIKE ?", "%#{params[:code]}%").page(params[:page]).per(15)
    elsif params[:from_date] && params[:to_date].present?
      # @date = params[:date]
      # @orders = ShoppingCart.where(buy_flag: true).where("updated_at LIKE ?", "%#{@date}%").page(params[:page]).per(15)
      @from_date = params[:from_date]
      @to_date = params[:to_date]
      # logger.debug("================== to date = #{@to_date.to_datetime.end_of_day}")
      @orders = ShoppingCart.where(buy_flag: true).where(updated_at: @from_date..@to_date.to_datetime.end_of_day).order(updated_at: "desc").page(params[:page]).per(15)
      # .where(updated_at: @from_date..@to_date)では 1日のみのスポット検索ができなかった
      # .where("updated_at between '#{@from_date}' and '#{@to_date} 23:59:59'") という書き方でもいけるが冗長
    elsif params[:customer_name].present?
      @customer_name = params[:customer_name].strip
      user = User.where("name LIKE ?", "%#{@customer_name}%")  # @customer_nameに入っている文字列のあいまい検索で引っかかった、該当 Userのインスタンスを代入
      # logger.debug("================== user = #{user}")
      user_id = User.where(id: user)  # userにはインスタンスが入っているので id検索が可能
      @orders = ShoppingCart.where(buy_flag: true).where(user_id: user_id).order(updated_at: "desc").page(params[:page]).per(15)
    else
      @orders = ShoppingCart.bought_carts.order(updated_at: "desc").page(params[:page]).per(15)
      # ShoppingCart.where(buy_flag: true).page(params[:page]).per(15)
    end
  end
end

class AddScoreToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :score, :integer, :unsigned => true, :default => 0
  end
end
# マイナスの値などは受け取らないようにunsigned => trueを記述
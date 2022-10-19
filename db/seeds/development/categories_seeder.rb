# このシーダーは先にmajor_categories_seeder.rbで親カテゴリを作成しておかないと動作しない

# major_category_names_and_ids = MajorCategory.major_category_name_and_id  #MajorCategory.all.pluck(:name, :id) 

# book_categories = ["ビジネス", "文学・評論", "人文・思想", "スポーツ", "コンピュータ・IT", "資格・検定・就職", "絵本・児童書", "写真集",
# "ゲーム攻略本", "雑誌", "アート・デザイン", "ノンフィクション"]

# computer_categories = ["ノートPC", "デスクトップPC", "タブレット"]

# display_categories = ["19~20インチ", "デスクトップPC", "タブレット"]

category_names = [
  [ 'book_categories', ["ビジネス", "文学・評論", "人文・思想", "スポーツ", "コンピュータ・IT", "資格・検定・就職", "絵本・児童書", "写真集",
  "ゲーム攻略本", "雑誌", "アート・デザイン", "ノンフィクション" ]],
  [ 'computer_categories', ["ノートPC", "デスクトップPC", "タブレット" ]],
  [ 'display_categories', ["19~20インチ", "デスクトップPC", "タブレット" ]]
  ]

category_names.each do |item|  #category_names配列の中の['book_categories', ["ビジネス", "文学・評論", "人文・思想"〜]]を取得し、ブロック変数itemに代入
    
  if item[0] == 'book_categories'
    item[1].each.with_index(1) do |name, index|  #item配列の["ビジネス", "文学・評論", "人文・思想"〜]だけを取得しブロック変数nameに代入
      Category.create(
        id: index,
        name: name,
        description: name,
        major_category_name: '本',
        major_category_id: 1
      )
    end
  elsif item[0] == 'computer_categories'
    item[1].each.with_index(13) do |name, index|
      Category.create(
        id: index,
        name: name,
        description: name,
        major_category_name: 'コンピュータ',
        major_category_id: 2
      )
    end
  elsif item[0] == 'display_categories'
    item[1].each.with_index(16) do |name, index|
      Category.create(
        id: index,
        name: name,
        description: name,
        major_category_name: 'ディスプレイ',
        major_category_id: 3
      )
    end
  end
end

  

#[["本", 1], ["コンピュータ", 2], ["ディスプレイ", 3]]
# major_category_names_and_ids.each do |major_category_name,major_category_id|
  
  # if major_category_name == "本"
    # book_categories.each_with_index do |book_category, index|
    #   i = index + 1
    #   Category.create(
    #     id: i,
    #     name: book_category,
    #     description: book_category,
    #     major_category_name: major_category_name,
    #     major_category_id: major_category_id
    #   )
    # end
    
  # elsif major_category_name == "コンピュータ"
  #   computer_categories.each_with_index do |computer_category, index|
  #     i = index + 1
  #     Category.create(
  #       id: i,
  #       name: computer_category,
  #       description: computer_category,
  #       major_category_name: major_category_name,
  #       major_category_id: major_category_id
  #     )
  #   end
    
  # elsif major_category_name == "ディスプレイ"
  #   display_categories.each_with_index do |display_category, index|
  #     i = index + 1
  #     Category.create(
  #       id: i,
  #       name: display_category,
  #       description: display_category,
  #       major_category_name: major_category_name,
  #       major_category_id: major_category_id
  #     )
  #   end
  # end
# end
  
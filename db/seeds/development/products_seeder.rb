product_ids = [*1..30]
category_ids = [*1..18,*1..12]
array_number = 0

product_ids.each do
  product_name = Faker::Music::RockBand.name
  Product.create(
    name: product_name,
    description: product_name,
    price: product_ids[array_number],
    category_id: category_ids[array_number]
  )
  array_number += 1
end

# 30.times do |i|
  
#     Product.create(
#     name: "product-{i+1}",
#     description: "description-{i+1}",
#     price: (i+1)*10,
#     category_id: category_ids[array_number]
#   )
  
# end
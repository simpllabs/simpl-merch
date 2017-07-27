class AddShopifyProductIdToTee < ActiveRecord::Migration[5.1]
  def change
    add_column :tees, :shopify_product_id, :string
  end
end

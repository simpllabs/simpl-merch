class AddShopifyOrderIdToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :shopify_order_id, :string
  end
end

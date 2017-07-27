class AddShopifyLineItemIdToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :shopify_line_item_id, :string
  end
end

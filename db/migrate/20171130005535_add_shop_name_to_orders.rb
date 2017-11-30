class AddShopNameToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :shop_name, :string
  end
end

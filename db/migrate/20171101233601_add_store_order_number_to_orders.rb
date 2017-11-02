class AddStoreOrderNumberToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :store_order_number, :integer
  end
end

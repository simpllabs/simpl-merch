class AddMulticolorToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :multicolor, :string
  end
end

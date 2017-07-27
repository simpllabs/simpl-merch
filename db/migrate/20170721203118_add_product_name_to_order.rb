class AddProductNameToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :product_name, :string
  end
end

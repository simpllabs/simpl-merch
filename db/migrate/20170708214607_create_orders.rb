class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :shop_domain
      t.string :fulfillment_status
      t.string :sku
      t.integer :quantity
      t.decimal :price, precision: 5, scale: 2
      t.string :name
      t.boolean :processed

      t.timestamps
    end
    add_index :orders, :shop_domain
  end
end

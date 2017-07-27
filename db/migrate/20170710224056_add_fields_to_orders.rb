class AddFieldsToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :address1, :string
    add_column :orders, :address2, :string
    add_column :orders, :company, :string
    add_column :orders, :city, :string
    add_column :orders, :zip, :string
    add_column :orders, :province, :string
    add_column :orders, :country, :string
  end
end

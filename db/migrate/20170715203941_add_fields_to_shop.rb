class AddFieldsToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :packing_slip, :string
    add_column :shops, :packing_slip_message, :text
    add_column :shops, :packing_slip_logo, :string
  end
end

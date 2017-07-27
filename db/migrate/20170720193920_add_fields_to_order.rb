class AddFieldsToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :front_ref, :string
    add_column :orders, :back_ref, :string
  end
end

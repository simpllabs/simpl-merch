class AddFieldToMaleInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :male_inventories, :gray_s, :integer
    add_column :male_inventories, :gray_m, :integer
    add_column :male_inventories, :gray_l, :integer
    add_column :male_inventories, :gray_xl, :integer
    add_column :male_inventories, :gray_2xl, :integer
    add_column :male_inventories, :gray_3xl, :integer
  end
end

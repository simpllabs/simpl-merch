class AddFieldToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :chose_china_post, :boolean
  end
end

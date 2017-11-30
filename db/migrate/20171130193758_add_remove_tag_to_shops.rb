class AddRemoveTagToShops < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :remove_tag, :string
  end
end

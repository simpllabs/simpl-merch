class RenameShopIdToShopDomain < ActiveRecord::Migration[5.1]
  def change
  	rename_column :tees, :shop_id, :shop_domain
    change_column :tees, :shop_domain, :string
  end
end

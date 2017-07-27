class AddEmailToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :email, :string
  end
end

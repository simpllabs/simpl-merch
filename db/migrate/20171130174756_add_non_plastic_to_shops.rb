class AddNonPlasticToShops < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :non_plastic, :string
  end
end

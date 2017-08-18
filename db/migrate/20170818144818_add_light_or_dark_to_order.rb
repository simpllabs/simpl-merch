class AddLightOrDarkToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :light_or_dark, :string
  end
end

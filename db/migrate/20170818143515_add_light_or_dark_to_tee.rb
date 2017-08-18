class AddLightOrDarkToTee < ActiveRecord::Migration[5.1]
  def change
    add_column :tees, :light_or_dark, :string
  end
end

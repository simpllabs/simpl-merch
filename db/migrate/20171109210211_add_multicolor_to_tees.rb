class AddMulticolorToTees < ActiveRecord::Migration[5.1]
  def change
    add_column :tees, :multicolor, :string
  end
end

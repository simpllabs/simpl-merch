class CreateFemaleInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :female_inventories do |t|
      t.integer :black_xs
      t.integer :black_s
      t.integer :black_m
      t.integer :black_l
      t.integer :black_xl
      t.integer :black_2xl
      t.integer :white_xs
      t.integer :white_s
      t.integer :white_m
      t.integer :white_l
      t.integer :white_xl
      t.integer :white_2xl
      t.integer :navy_xs
      t.integer :navy_s
      t.integer :navy_m
      t.integer :navy_l
      t.integer :navy_xl
      t.integer :navy_2xl
      t.integer :green_xs
      t.integer :green_s
      t.integer :green_m
      t.integer :green_l
      t.integer :green_xl
      t.integer :green_2xl
      t.integer :red_xs
      t.integer :red_s
      t.integer :red_m
      t.integer :red_l
      t.integer :red_xl
      t.integer :red_2xl

      t.timestamps
    end
  end
end

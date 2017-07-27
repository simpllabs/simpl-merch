class CreateTees < ActiveRecord::Migration[5.1]
  def change
    create_table :tees do |t|
      t.text :tee_front_url
      t.text :tee_back_url
      t.integer :shop_id

      t.timestamps
    end
  end
end

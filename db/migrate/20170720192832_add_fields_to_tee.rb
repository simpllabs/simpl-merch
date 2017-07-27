class AddFieldsToTee < ActiveRecord::Migration[5.1]
  def change
    add_column :tees, :tee_front_ref, :string
    add_column :tees, :tee_back_ref, :string
  end
end

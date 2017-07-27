class AddGenderToTee < ActiveRecord::Migration[5.1]
  def change
    add_column :tees, :gender, :string
  end
end

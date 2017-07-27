class AddGenderToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :gender, :string
  end
end

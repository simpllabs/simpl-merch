class AddFrontDesignAndBackDesignToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :front_design, :string
    add_column :orders, :back_design, :string
  end
end

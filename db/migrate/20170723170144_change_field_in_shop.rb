class ChangeFieldInShop < ActiveRecord::Migration[5.1]
  def change
  	change_column :shops, :chose_china_post, :string
  end
end

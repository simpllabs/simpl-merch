class AddTrialExtentionLinkToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :trial_extention_link, :text
  end
end

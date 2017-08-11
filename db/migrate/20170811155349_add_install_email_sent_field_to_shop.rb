class AddInstallEmailSentFieldToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :install_email_sent, :boolean
  end
end

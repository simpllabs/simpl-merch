class AddSendReceiptsToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :send_receipts, :string
  end
end

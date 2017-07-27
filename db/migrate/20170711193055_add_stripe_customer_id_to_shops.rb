class AddStripeCustomerIdToShops < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :stripe_customer_id, :string
  end
end

class AddOneTimeFeeChargedToTee < ActiveRecord::Migration[5.1]
  def change
    add_column :tees, :one_time_fee_charged, :boolean
  end
end

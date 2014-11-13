class ChangeColumnPickupDateToString < ActiveRecord::Migration
  def change
    change_column :orders, :pickup_date, :string
  end
end

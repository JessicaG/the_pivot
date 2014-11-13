class AddColumnPickupLocationToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :pickup_location, :string
  end
end

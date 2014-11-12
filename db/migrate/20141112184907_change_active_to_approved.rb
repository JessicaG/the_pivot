class ChangeActiveToApproved < ActiveRecord::Migration
  def change
    rename_column :vendors, :active, :approved
  end
end

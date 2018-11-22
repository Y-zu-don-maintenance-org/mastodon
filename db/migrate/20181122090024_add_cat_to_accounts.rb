class AddCatToAccounts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :accounts, :cat, :boolean, default: false, null: false
  end
end

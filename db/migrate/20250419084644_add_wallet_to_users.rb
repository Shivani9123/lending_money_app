class AddWalletToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :wallet, :decimal
  end
end

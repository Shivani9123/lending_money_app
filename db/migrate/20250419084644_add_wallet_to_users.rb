class AddWalletToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :wallet, :decimal
  end
end

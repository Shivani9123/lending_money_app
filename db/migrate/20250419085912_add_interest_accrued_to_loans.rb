class AddInterestAccruedToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :interest_accrued, :decimal
    add_column :loans, :last_interest_applied_at, :datetime
  end
end

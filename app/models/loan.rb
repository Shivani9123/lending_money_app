class Loan < ApplicationRecord
  belongs_to :user

  enum status: {
    requested: "requested",
    approved: "approved",
    open: "open",
    closed: "closed",
    rejected: "rejected",
    waiting_for_adjustment_acceptance: "waiting_for_adjustment_acceptance",
    readjustment_requested: "readjustment_requested"
  }

  def total_amount_due
    amount + interest_accrued.to_f
  end
end

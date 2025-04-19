class CalculateInterestJob < ApplicationJob
  queue_as :default

  def perform
    Loan.open.find_each do |loan|
      time_diff = ((Time.current - (loan.last_interest_applied_at || loan.updated_at)) / 60).to_i
      next if time_diff < 5

      intervals = time_diff / 5
      return if intervals.zero?

      interest = (loan.amount * (loan.interest_rate / 100.0) * (5.0 / (365 * 24 * 60))) * intervals

      loan.update!(
        interest_accrued: loan.interest_accrued.to_f + interest,
        last_interest_applied_at: Time.current
      )
    end
  end
end

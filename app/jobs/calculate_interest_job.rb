class CalculateInterestJob < ApplicationJob
  queue_as :default

  def perform
    Loan.where(status: :open).find_each do |loan|
      loan.update(amount: loan.amount + (loan.amount * loan.interest_rate / 100 / 12))
    end
  end
end

class Admin::LoansController < ApplicationController
  before_action :check_admin

  def index
    @loans = Loan.all
  end

  def update
    @loan = Loan.find(params[:id])

    case params[:status]
    when 'approved'
      ApplicationRecord.transaction do
        admin = current_user
        user = @loan.user
        amount = @loan.amount.to_f

        raise "Admin has insufficient balance" if admin.wallet < amount

        admin.update!(wallet: admin.wallet - amount)
        user.update!(wallet: user.wallet + amount)

        # Loan goes to open state
        @loan.update!(status: :open, last_interest_applied_at: Time.current)
      end
    when 'rejected'
      @loan.update(status: :rejected)
    when 'adjusted'
      # If the loan is adjusted (interest/amount), it goes to waiting_for_adjustment_acceptance
      @loan.update(status: :waiting_for_adjustment_acceptance)
    when 'waiting_for_adjustment_acceptance'
      # Handle user acceptance or rejection after admin adjustment
      if params[:accept_adjustment] == 'true'
        # User accepts the adjustment
        @loan.update(status: :open, last_interest_applied_at: Time.current)
      elsif params[:accept_adjustment] == 'false'
        # User rejects the adjustment
        @loan.update(status: :rejected)
      else
        # If the user wants a readjustment
        @loan.update(status: :readjustment_requested)
      end
    end

    redirect_to admin_loans_path, notice: "Loan updated successfully"
  rescue => e
    redirect_to admin_loans_path, alert: e.message
  end
end

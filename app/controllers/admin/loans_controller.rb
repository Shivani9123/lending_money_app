class Admin::LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @loans = Loan.all
  end

  def update
    @loan = Loan.find(params[:id])

    case params[:status]
    when 'approved'
      approve_loan(@loan)
    when 'rejected'
      reject_loan(@loan)
    when 'adjusted'
      adjust_loan(@loan)
    when 'waiting_for_adjustment_acceptance'
      handle_adjustment_acceptance(@loan)
    end

    redirect_to admin_loans_path, notice: "Loan updated successfully"
  rescue => e
    redirect_to admin_loans_path, alert: e.message
  end

  private

  def approve_loan(loan)
    ApplicationRecord.transaction do
      admin = current_user
      user = loan.user
      amount = loan.amount.to_f

      raise "Admin has insufficient balance" if admin.wallet < amount

      admin.update!(wallet: admin.wallet - amount)
      user.update!(wallet: user.wallet + amount)

      loan.update!(status: :open, last_interest_applied_at: Time.current)
    end
  end

  def reject_loan(loan)
    loan.update(status: :rejected)
    flash[:alert] = "Loan has been rejected."
  end

  def adjust_loan(loan)
    # If the loan is adjusted (interest/amount), it goes to waiting_for_adjustment_acceptance
    loan.update(status: :waiting_for_adjustment_acceptance)
    flash[:notice] = "Loan has been adjusted. Await user acceptance."
  end

  def handle_adjustment_acceptance(loan)
    # Handle user acceptance or rejection after admin adjustment
    if params[:accept_adjustment] == 'true'
      loan.update(status: :open, last_interest_applied_at: Time.current)
      flash[:notice] = "Adjustment accepted. Loan status updated to open."
    elsif params[:accept_adjustment] == 'false'
      loan.update(status: :rejected)
      flash[:notice] = "Adjustment rejected. Loan status updated to rejected."
    else
      # If the user wants a readjustment
      loan.update(status: :readjustment_requested)
      flash[:notice] = "User has requested further readjustment."
    end
  end
end

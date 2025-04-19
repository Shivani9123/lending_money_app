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
  
        @loan.update!(status: :open, last_interest_applied_at: Time.current)
      end
    when 'rejected'
      @loan.update(status: :rejected)
    end
  
    redirect_to admin_loans_path, notice: "Loan updated successfully"
  rescue => e
    redirect_to admin_loans_path, alert: e.message
  end
end

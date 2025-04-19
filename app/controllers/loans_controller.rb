class LoansController < ApplicationController

  def index
    @loans = current_user.loans
  end

  def new
    @loan = Loan.new
  end

  def create
    @loan = current_user.loans.build(loan_params)
    @loan.status = :requested

    if @loan.save
      redirect_to loans_path, notice: 'Loan requested successfully'
    else
      render :new
    end
  end

  def repay
    @loan = current_user.loans.find(params[:id])
    total_due = @loan.total_amount_due.to_f
  
    if current_user.wallet.to_f >= total_due
      ApplicationRecord.transaction do
        current_user.update!(wallet: current_user.wallet - total_due)
  
        # Assume admin receives the repayment
        admin = User.find_by(role: :admin)
        admin.update!(wallet: admin.wallet + total_due)
  
        @loan.update!(status: :closed)
      end
      redirect_to loans_path, notice: "Loan repaid successfully"
    else
      redirect_to loans_path, alert: "Insufficient wallet balance"
    end
  end

  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end
end

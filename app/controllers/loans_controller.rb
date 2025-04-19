class LoansController < ApplicationController
  before_action :authenticate_user!

  def index
    @loans = current_user.loans
  end

  def new
    if current_user.loans.where(status: [ "open", "approved" ]).exists?
      redirect_to loans_path, alert: "You already have an open or approved loan."
    else
      @loan = Loan.new
    end
  end

  def create
    @loan = current_user.loans.build(loan_params)
    @loan.status = :requested

    if @loan.amount > current_user.wallet
      flash[:alert] = "Insufficient funds to request this loan."
      render :new and return
    end

    if @loan.save
      redirect_to loans_path, notice: "Loan requested successfully"
    else
      flash[:alert] = "Failed to request loan. Please check your input."
      render :new
    end
  end

  def repay
    @loan = current_user.loans.find(params[:id])

    # Ensure loan is open for repayment
    if @loan.status != "open"
      return redirect_to loans_path, alert: "This loan cannot be repaid yet."
    end

    total_due = @loan.total_amount_due.to_f

    if current_user.wallet.to_f >= total_due
      ApplicationRecord.transaction do
        current_user.update!(wallet: current_user.wallet - total_due)

        admin = User.find_by(role: :admin)
        raise ActiveRecord::RecordNotFound, "Admin not found" unless admin

        admin.update!(wallet: admin.wallet + total_due)
        @loan.update!(status: :closed)
      end
      redirect_to loans_path, notice: "Loan repaid successfully"
    else
      redirect_to loans_path, alert: "Insufficient wallet balance"
    end
  rescue ActiveRecord::RecordNotFound => e
    redirect_to loans_path, alert: "An error occurred: #{e.message}"
  rescue StandardError => e
    redirect_to loans_path, alert: "Something went wrong: #{e.message}"
  end

  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end
end

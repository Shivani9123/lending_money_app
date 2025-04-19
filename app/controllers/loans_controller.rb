class LoansController < ApplicationController
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

  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end
end

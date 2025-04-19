class Admin::LoansController < ApplicationController
  before_action :check_admin

  def index
    @loans = Loan.all
  end

  def update
    @loan = Loan.find(params[:id])

    case params[:status]
    when 'approved'
      @loan.update(status: :approved)
    when 'rejected'
      @loan.update(status: :rejected)
    when 'adjusted'
      # Handle adjustment logic
    end

    redirect_to admin_loans_path
  end
end

class LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan, only: [:confirm, :show]

  def index
    @loans = current_user.admin? ? Loan.all : current_user.loans
  end

  def new
    @loan = Loan.new
  end

  def show

  end

  def create
    @loan = current_user.loans.new(loan_params)
    if @loan.save
      redirect_to loans_path, notice: "Loan request submitted successfully."
    else
      render :new
    end
  end

  def confirm
    if params[:type] == 'confirmed'
      @loan.update(is_confirmed: true, status: :open)
    elsif params[:type] == 'rejected'
      @loan.update(is_confirmed: false, status: :rejected)
    end
    redirect_to loans_path, notice: "Your Loan Confirmation request has been #{@loan.is_confirmed? ? "Accepted" : "Rejected"}."
  end

  def repay
    @loan = Loan.find(params[:id])
    total_due = @loan.total_amount
    user_wallet = current_user.wallet
    admin_wallet = User.admin.wallet

    amount_to_repay = [total_due, user_wallet.balance].min
    ActiveRecord::Base.transaction do
      user_wallet.update!(balance: user_wallet.balance - amount_to_repay)
      admin_wallet.update!(balance: admin_wallet.balance + amount_to_repay)

      @loan.update!(status: :closed)
    end

    redirect_to loans_path, notice: "Loan repaid successfully."
  rescue StandardError => e
    redirect_to loans_path, alert: "Error processing repayment: #{e.message}"
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end
end

class Admin::LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_loan, only: %i[approve reject]
  before_action :check_admin_wallet, only: :approve

  def index
    @loans = Loan.all
  end

  def approve
    if loan_adjustment_params.present?
      @loan.loan_adjustments.create!(loan_adjustment_params)
      @loan.update!(status: :waiting_for_adjustment_acceptance)
    else
      @loan.update!(status: :approved)
    end

    respond_with_notice("Loan status updated.")
  end

  def reject
    @loan.update!(status: :rejected)
    
    if params[:type] == 'reject_adjustment'
      @loan.loan_adjustments.order(created_at: :desc).first&.update!(status: :rejected)
    end

    respond_with_notice("Loan has been rejected.")
  end

  private

  def loan_adjustment_params
    params.fetch(:loan, {}).permit(:adjusted_amount, :adjusted_interest_rate).compact_blank
  end

  def ensure_admin
    redirect_to root_path, alert: "Access Denied" unless current_user.admin?
  end

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def check_admin_wallet
    required_amount = loan_adjustment_params[:adjusted_amount] || @loan.amount
    unless current_user.wallet.balance >= required_amount.to_i
      redirect_to loans_path, alert: "Admin has insufficient balance to approve or adjust this loan amount."
    end
  end

  def respond_with_notice(message)
    # respond_to do |format|
    #   # format.turbo_stream
    #   # format.html { redirect_to admin_loans_path, notice: message }
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace("loan_#{@loan.id}", partial: "admin/loans/loan_row", locals: { loan: @loan }) }
    #   format.html { redirect_to admin_loans_path, notice: message }
    # end

    respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("loan_#{@loan.id}", partial: "admin/loans/loan_row", locals: { loan: @loan }),
            turbo_stream.replace("modal", "") # 🚀 Fix: Remove Modal After Submission
          ]
        end
        format.html { redirect_to admin_loans_path, notice: "Loan approved successfully." }
      end
  end
end

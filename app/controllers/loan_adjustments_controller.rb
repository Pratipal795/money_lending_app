class LoanAdjustmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user, only: :adjust_loan
  before_action :set_loan_adjustment, only: %i[show adjust_loan]

  def show
  end

  def index
    @loan_adjustments = current_user.admin? ? LoanAdjustment.all : current_user.loan_adjustments
  end

  def adjust_loan
    case params[:type]
    when 'approved'
      @loan_adjustment.update(status: :accepted)
      @loan_adjustment.loan.update(status: :open, total_amount: @loan_adjustment.adjusted_amount)
    when 'rejected'
      @loan_adjustment.update(status: :rejected)
      @loan_adjustment.loan.update(status: :rejected)
    when 're_adjustment'
      @loan_adjustment.update(status: :readjustment_requested)
      @loan_adjustment.loan.update(status: :readjustment_requested)
    else
      redirect_to loans_path, alert: "Invalid adjustment type."
    end
    redirect_to loans_path, notice: "Your loan confirmation request has been #{params[:type]}."
  end


  private

  def ensure_user
    redirect_to root_path, alert: "Access Denied" unless current_user.user?
  end

  def set_loan_adjustment
    @loan_adjustment = LoanAdjustment.find(params[:id])
  end
end

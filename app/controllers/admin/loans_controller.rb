class Admin::LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_loan, only: %i[approve reject get_modal_popup]
  before_action :check_admin_wallet, only: :approve
  before_action :validate_adjustment_params, only: :approve

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

  # def approve
  #   if loan_adjustment_params.present?
  #     if loan_adjustment_params[:adjusted_amount].to_f <= 0 || loan_adjustment_params[:adjusted_interest_rate].to_f <= 0
  #       @loan.errors.add(:base, "Adjusted amount and interest rate must be greater than 0")
  #       respond_to do |format|
  #         format.turbo_stream do
  #           render turbo_stream: turbo_stream.replace("remote_modal", partial: "admin/loans/adjust_modal_form", locals: { loan: @loan })
  #         end
  #       end
  #       return
  #     end

  #     @loan.loan_adjustments.create!(loan_adjustment_params)
  #     @loan.update!(status: :waiting_for_adjustment_acceptance)
  #   else
  #     @loan.update!(status: :approved)
  #   end

  #   respond_with_notice("Loan status updated.")
  # end



  def reject
    @loan.update!(status: :rejected)
    
    if params[:type] == 'reject_adjustment'
      @loan.loan_adjustments.order(created_at: :desc).first&.update!(status: :rejected)
    end

    respond_with_notice("Loan has been rejected.")
  end

  def get_modal_popup
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
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("loan_#{@loan.id}", partial: "admin/loans/loan_row", locals: { loan: @loan })
        ]
      end
      format.html { redirect_to admin_loans_path, notice: "Loan approved successfully." }
    end
  end

  def validate_adjustment_params
    return unless loan_adjustment_params.present?

    if loan_adjustment_params[:adjusted_amount].to_f <= 0 || loan_adjustment_params[:adjusted_interest_rate].to_f <= 0
      @loan.errors.add(:base, "Adjusted amount and interest rate must be greater than 0")

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "remote_modal",
            partial: "admin/loans/adjust_modal_form",
            locals: { loan: @loan }
          )
        end
      end
      return false # to halt the action
    end
  end
end

class InterestCalculatorJob < ApplicationJob
  queue_as :default

  def perform
    Loan.open.each do |loan|
      latest_adjustment = loan.loan_adjustments.order(created_at: :desc).first
      interest = if latest_adjustment.present?
        latest_adjustment.adjusted_amount * (latest_adjustment.adjusted_interest_rate / 100)
      else
        loan.amount * (loan.interest_rate / 100)
      end
      loan.update(total_amount: loan.total_amount + interest)
    end
  end
end

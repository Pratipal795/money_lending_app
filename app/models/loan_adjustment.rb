class LoanAdjustment < ApplicationRecord
  belongs_to :loan

  enum status: {
    pending: 0, # Waiting for user response
    accepted: 1, # User accepted the adjustment
    rejected: 2, # User rejected the adjustment
    readjustment_requested: 3 # User requested another adjustment
  }

  validates :adjusted_amount, numericality: { greater_than: 0 }
  validates :adjusted_interest_rate, numericality: { greater_than: 0 }

end
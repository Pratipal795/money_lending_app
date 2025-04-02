class LoanConfirmationNotification < ApplicationRecord
	belongs_to :loan

  enum status: {
    pending: 0, # Waiting for user response
    accepted: 1, # User accepted the adjustment
    rejected: 2, # User rejected the adjustment
    readjustment_requested: 3 # User requested another adjustment
  }

end

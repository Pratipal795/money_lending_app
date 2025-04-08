class Loan < ApplicationRecord
  belongs_to :user
  has_many :loan_adjustments, dependent: :destroy

  enum status: {
    requested: 0,
    approved: 1,
    rejected: 2,
    open: 3,
    waiting_for_adjustment_acceptance: 4,
    readjustment_requested: 5,
    closed: 6
  }

  validates :amount, :interest_rate, presence: true, numericality: { greater_than: 0 }

  after_create :set_requested_status
  after_update :transfer_funds_if_open, if: :saved_change_to_status?

  def valid_repay_amount
    if self.user.wallet.balance >= self.total_amount
      total_amount
    else
      self.user.wallet.balance
    end
  end

  private

  def set_requested_status
    self.status ||= :requested
  end

  after_initialize do
    self.total_amount ||= amount if new_record?
  end


  def transfer_funds_if_open
    return unless open?

    admin_wallet = Wallet.find_by(user: User.admin)
    user_wallet = user.wallet
    transfer_amount = loan_adjustments.order(created_at: :desc).limit(1).pluck(:adjusted_amount).first || amount

    if admin_wallet.balance >= transfer_amount
      ActiveRecord::Base.transaction do
        admin_wallet.decrement!(:balance, transfer_amount)
        user_wallet.increment!(:balance, transfer_amount)
      end
    else
      errors.add(:base, "Insufficient funds in admin wallet")
      raise ActiveRecord::Rollback
    end
  end
end

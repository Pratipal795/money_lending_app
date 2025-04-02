class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  enum role: { user: 0, admin: 1 }
  has_one :wallet, dependent: :destroy
  has_many :loans, dependent: :destroy
  has_many :loan_adjustments, through: :loans, dependent: :destroy
  after_create :create_wallet

  private

  def create_wallet
    initial_balance = admin? ? 1_000_000 : 10_000
    Wallet.create(user: self, balance: initial_balance)
  end

  def self.admin
    User.find_by(role: 'admin')
  end
end

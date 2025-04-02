class AddLoanAdjustmentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :loan_adjustments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :adjusted_amount, precision: 15, scale: 2
      t.decimal :adjusted_interest_rate, precision: 5, scale: 2
      t.integer :status, default: 0 # Default to 'pending'
      t.timestamps
    end
  end
end

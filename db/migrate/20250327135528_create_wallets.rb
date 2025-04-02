class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :balance, default: 0

      t.timestamps
    end
  end
end

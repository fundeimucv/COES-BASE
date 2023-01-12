class CreateBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_accounts do |t|
      t.string :number, unique: true, null: false
      t.string :holder, unique: true, null: false
      t.references :bank, null: false, foreign_key: true
      t.integer :acount_type

      t.timestamps
    end
  end
end

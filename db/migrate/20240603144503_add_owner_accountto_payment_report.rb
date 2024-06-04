class AddOwnerAccounttoPaymentReport < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_reports, :owner_account_name, :string
    add_column :payment_reports, :owner_account_ci, :string
    add_column :payment_reports, :status, :integer, default: 0, null: false
  end
end

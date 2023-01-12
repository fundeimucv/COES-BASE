class AddBankAccountToSchool < ActiveRecord::Migration[7.0]
  def change
    add_reference :schools, :bank_account
  end
end

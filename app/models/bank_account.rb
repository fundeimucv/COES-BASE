class BankAccount < ApplicationRecord
  # t.string "number", null: false
  # t.string "holder", null: false
  # t.bigint "bank_id", null: false
  # t.integer "acount_type"

  # ENUMERIZE:
  enum account_type: [:ahorro, :corriente]

  # ASSOCIATIONS:
  belongs_to :bank
  has_one :school

  rails_admin do
    navigation_label 'Finanzas'
    navigation_icon 'fa-solid fa-piggy-bank'
  end  
end

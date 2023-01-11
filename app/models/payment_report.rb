class PaymentReport < ApplicationRecord
  # SCHEMA:
  # t.float "amount"
  # t.string "transaction_id"
  # t.integer "transaction_type"
  # t.date "transaction_date"
  # t.bigint "origin_bank_id", null: false
  # t.string "payable_type"
  # t.bigint "payable_id"  

  # ASSOCIATIONS:
  belongs_to :origin_bank, class_name: 'Bank', foreign_key: 'origin_bank_id'
  belongs_to :payable, polymorphic: true

  # VALIDATIONS:
  validates :payable_id, presence: true
  validates :payable_type, presence: true

  rails_admin do
    navigation_label 'Finanzas'
    navigation_icon 'fa-solid fa-cash-register'
  end  
end

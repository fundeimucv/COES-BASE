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
  # validates :payable_id, presence: true
  # validates :payable_type, presence: true
  validates :payable, presence: true
  validates :amount, presence: true
  validates :transaction_id, presence: true
  validates :transaction_type, presence: true
  validates :transaction_date, presence: true
  validates :origin_bank, presence: true

  enum transaction_type: [:transferencia, :efectivo, :punto_venta]

  rails_admin do
    navigation_label 'Finanzas'
    navigation_icon 'fa-solid fa-cash-register'

    export do
      fields :amount, :transaction_id, :transaction_type, :transaction_date, :origin_bank_id, :origin_bank
      field :payable_type do
        label 'Tipo'
      end
      field :payable_id do
        label 'Id'
      end

    end
  end  
end

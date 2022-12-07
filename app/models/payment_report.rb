class PaymentReport < ApplicationRecord
  # ASSOCIATIONS:
  belongs_to :origin_bank
  belongs_to :payable, polymorphic: true

  # VALIDATIONS:
  validates :payable_id, presence: true
  validates :payable_type, presence: true
end

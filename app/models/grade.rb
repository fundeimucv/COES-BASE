class Grade < ApplicationRecord
  belongs_to :student
  belongs_to :study_plan
  belongs_to :admission_type
  has_many :payment_reports, as: :payable

  enum registration_status: [:universidad, :facultad, :escuela]
  enum graduate_status: [:no_graduable, :tesista, :posible_graduando, :graduando, :graduado]

end

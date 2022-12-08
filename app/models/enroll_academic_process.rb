class EnrollAcademicProcess < ApplicationRecord
  belongs_to :grade
  belongs_to :academic_process
  has_many :payment_reports, as: :payable

  enum enroll_status: [:preinscrito, :reservado, :confirmado, :retirado]
  enum permanence_status: [:nuevo, :regular, :reincorporado, :articulo3, :articulo6, :articulo7]  
end

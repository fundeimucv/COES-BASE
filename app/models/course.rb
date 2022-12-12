class Course < ApplicationRecord
  # SCHEMA:
  # t.bigint "academic_process_id", null: false
  # t.bigint "subject_id", null: false
  # t.boolean "offer_as_pci"

  # ASSOCIATIONS:
  # belongs_to
  belongs_to :academic_process
  belongs_to :subject
  
  # has_many
  has_many :sections

  #VALIDATIONS:
  validates :subject, presence: true
  validates :academic_process, presence: true
  
end

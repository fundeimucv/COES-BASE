class Course < ApplicationRecord
  # SCHEMA:
  # t.bigint "academic_process_id", null: false
  # t.bigint "subject_id", null: false
  # t.boolean "offer_as_pci"

  # ASSOCIATIONS:
  # belongs_to
  belongs_to :academic_process
  has_one :period, through: :academic_process
  has_one :school, through: :academic_process
  belongs_to :subject
  
  # has_many
  has_many :sections, dependent: :destroy

  #VALIDATIONS:
  validates :subject, presence: true
  validates :academic_process, presence: true

  scope :pcis, -> {where(offer_as_pci: true)}

  def name 
    "#{self.period.name}-#{self.subject.desc}" if self.period and self.school and self.subject
  end

  def total_sections
    sections.count
  end

  rails_admin do
    visible false
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-shapes'

    list do
      fields :academic_process, :subject
      field :total_sections
    end

    show do
      fields :academic_process, :subject, :sections
    end

    edit do
      fields :academic_process, :subject#, :sections
    end

    export do
      fields :academic_process, :subject
    end


  end
  
end

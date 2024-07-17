# == Schema Information
#
# Table name: programaciones
#
#  pci           :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  asignatura_id :string(255)
#  periodo_id    :string(255)
#
# Indexes
#
#  index_programaciones_on_asignatura_id                 (asignatura_id)
#  index_programaciones_on_asignatura_id_and_periodo_id  (asignatura_id,periodo_id) UNIQUE
#  index_programaciones_on_periodo_id                    (periodo_id)
#  index_programaciones_on_periodo_id_and_asignatura_id  (periodo_id,asignatura_id) UNIQUE
#
class Programacion < ApplicationRecord
  self.table_name = 'programaciones'
  # ASOCIACIONES:
  belongs_to :asignatura
  belongs_to :periodo

  has_one :departamento, through: :asignatura 
  has_one :escuela, through: :departamento
  
  before_create :set_pci

  def set_pci
    self.pci = false
  end

  def find_course
    ep = Escuelaperiodo.where(escuela_id: escuela.id, periodo_id: periodo_id).first
    ap = ep.find_or_create_academic_process
    subject = asignatura.find_subject
    Course.where(academic_process_id: ap.id, subject_id: subject.id).first if subject and ap
  end
  def find_or_create_course
    ep = Escuelaperiodo.where(escuela_id: escuela.id, periodo_id: periodo_id).first
    ap = ep.find_or_create_academic_process
    subject = asignatura.find_subject
    Course.find_or_create_by(academic_process_id: ap.id, subject_id: subject.id) if subject and ap
  end  
  def import_course

    ep = Escuelaperiodo.where(escuela_id: escuela.id, periodo_id: periodo_id).first
    ap = ep.find_or_create_academic_process
    # p "Academic Process: #{ac.name}"
    subject = asignatura.find_subject
    
    if subject.nil?
      p "Asignatura_id: #{asignatura_id}" 
    else
      c = Course.find_or_initialize_by(academic_process_id: ap.id, subject_id: subject.id)
      if c.new_record?
        c.offer_as_pci = pci
        c.save ? '+' : "Errors: #{c.errors.full_messages.to_sentence}"
      else
        '='
      end
    end

  end

  def descripcion
    "#{asignatura_id}-#{periodo_id}"
  end

  scope :pcis, -> {where("programaciones.pci IS TRUE")}
  scope :del_periodo, lambda {|periodo_id| where(periodo_id: periodo_id)}
  scope :de_la_escuela, lambda {|escuela_id| joins(:asignatura).joins(:departamento).where('escuela_id = ?', escuela_id)}

end

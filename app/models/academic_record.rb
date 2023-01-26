class AcademicRecord < ApplicationRecord
  # SCHEMA:
  # t.bigint "section_id", null: false
  # t.bigint "enroll_academic_process_id", null: false
  # t.float "first_q"
  # t.float "second_q"
  # t.float "third_q"
  # t.float "final_q"
  # t.float "post_q"
  # t.integer "status_q"
  # t.integer "type_q"

  # CONSTANTENIZE:
  Q_DIFERIDO = 'ND'
  Q_FINAL = 'NF'
  Q_REPARACION = 'NR'
  Q_PI = 'PI'  
  Q_PARCIAL = 'PR'

  # ENUMERIZE:
  enum status_q: [:sin_calificar, :aprobado, :aplazado, :retirado, :trimestre1, :trimestre2]
  enum type_q: [:diferido, :final, :reparacion, :perdida_por_inasistencia, :parcial]
  # enum status_q: [:sc, :a, :ap, :re, :t1, :t2]
  # enum type_q: [:nd, :nf, :rep, :pi, :par]

  # ASSOCIATIONS:
  belongs_to :section
  belongs_to :enroll_academic_process

  has_one :academic_process, through: :enroll_academic_process
  has_one :grade, through: :enroll_academic_process
  has_one :study_plan, through: :grade
  has_one :student, through: :grade
  has_one :location, through: :student
  has_one :user, through: :student
  has_one :period, through: :academic_process
  has_one :period_type, through: :period
  has_one :course, through: :section
  has_one :teacher, through: :section
  has_one :subject, through: :course

  # VALIDATIONS:
  validates :section, presence: true
  validates :enroll_academic_process, presence: true
  validates :type_q, presence: true
  validates :status_q, presence: true

  # FUNCTIONS:
  def name
    "#{user.ci_fullname} en #{section.name}" if (user and section)
  end

  def pi?
    perdida_por_inasistencia?
  end

  def set_definitive_q
    have_post_q? ? set_post_q : set_final_q
  end

  def set_final_q
    if retirado? 
      return '--'
    elsif self.final_q.nil?
      return 'SN'
    elsif subject.as_absolute?
      valor = I18n.t(self.aprobado? ? 'aprobado' : 'aplazado')
    else
      return sprintf("%02i", self.final_q)
    end   
  end

  def set_post_q
    if self.post_q.nil?
      return 'SN'
    else
      return sprintf("%02i", self.post_q)
    end   
  end


  def description_q force_final = false

    valor = ''
    if retirado?
      valor = 'RETIRADO'
    elsif pi?
      valor = 'PÉRDIDA POR INASISTENCIA'
    elsif sin_calificar? || trimestre1? || trimestre2?
      valor = 'POR DEFINIR'
    elsif self.subject.as_absolute?
      valor = self.status_q.upcase
    elsif force_final or !have_post_q?
      valor = num_to_s
    else
      valor = num_to_s post_q
    end
    return valor
  end

  def num_to_s num = final_q
    numeros = %W(CERO UNO DOS TRES CUATRO CINCO SEIS SIETE OCHO NUEVE DIEZ ONCE DOCE TRECE CATORCE QUINCE)

    'CALIFICACIÓN PENDIENTE' if num.nil? or !(num.is_a? Integer or num.is_a? Float)
    num = num.to_i
      
    if num < 10 
      "#{numeros[0]} #{numeros[num]}"
    elsif num >= 10  and num < 16
      numeros[num]
    elsif num >= 16 and num < 20
      aux = num % 10
      "#{numeros[10]} Y #{numeros[aux]}"
    elsif num == 20
      'VEINTE'
    else
      'CALIFICACIÓN PENDIENTE'
    end
  end


  def have_post_q?
    (self.reparacion? || self.diferido?) and !self.post_q.nil?
  end

  def conv_descrip force_final = false # convocados

    data = [self.user.ci, self.user.reverse_name, self.study_plan.code]

    if force_final
      data << I18n.t('aplazado')
      data << I18n.t('final')
      data << h.set_final_q unless self.subject.as_absolute?
      data << self.description_q(force_final)
    else
      data << I18n.t(self.status_q)
      data << I18n.t(type_q)
      data << self.set_definitive_q unless self.subject.as_absolute?
      data << self.description_q
    end

    return data

  end



  # RAILS_ADMIN
  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-signature'

    list do
      field :period do
        searchable :name
        filterable :name
        sortable :name
      end
      field :subject do
        searchable :name
        filterable :name
        sortable :name
      end
      field :student do
        searchable :name
        filterable :name
        sortable :name
      end
      field :final_q
      field :status_q
      field :type_q
    end

    edit do
      fields :section, :enroll_academic_process, :first_q, :second_q, :third_q, :final_q, :post_q, :status_q, :type_q
    end


    export do
      fields :final_q, :status_q, :type_q, :section, :enroll_academic_process, :period, :period_type, :student, :user, :location, :subject
    end


  end  

end

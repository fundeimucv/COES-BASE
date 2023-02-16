class AcademicRecord < ApplicationRecord
  # SCHEMA:
  # t.bigint "section_id", null: false
  # t.bigint "enroll_academic_process_id", null: false
  # t.integer "status"

  # ENUMERIZE:
  enum status: [:sin_calificar, :aprobado, :aplazado, :retirado, :perdida_por_inasistencia]

  # ASSOCIATIONS:
  belongs_to :section
  belongs_to :enroll_academic_process

  has_many :qualifications, dependent: :destroy

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
  validates :status, presence: true
  # validates :final_q, numericality: { in: 0..20 }, allow_blank: true

  # CALLBACK
  after_save :set_options_q

  # TRIGGER FUNCTIONS:
  def set_options_q
    self.qualifications.destroy_all if self.pi? or self.retirado? or (self.subject and self.subject.absoluta?)
  end

  # SCOPE:
  scope :custom_search, -> (keyword) { joins(:user, :subject).where("users.ci ILIKE '%#{keyword}%' OR users.email ILIKE '%#{keyword}%' OR users.first_name ILIKE '%#{keyword}%' OR users.last_name ILIKE '%#{keyword}%' OR users.number_phone ILIKE '%#{keyword}%' OR subjects.name ILIKE '%#{keyword}%' OR subjects.code ILIKE '%#{keyword}%'") }
  
  # FUNCTIONS:

  def set_status valor
    valor.strip!
    valor.upcase!

    if (valor.eql? 'PI' or valor.eql? 'RT' or valor.eql? 'A' or valor.eql? 'AP')
      self.status = I18n.t(valor)
      return true
    else
      qua = self.qualifications.find_or_initialize_by(type_q: :final)
      qua.value = valor.to_i
      return qua.save
    end
    return false
  end

  def student_name_with_retiro
    aux = "#{user.reverse_name}"
    aux += " <div class='badge bg-danger'>Retirada</div>" if retirado? 
    return aux
  end

  def tr_class_by_status_q
    valor = ''
    valor = 'table-success' if self.aprobado?
    valor = 'table-danger' if (self.aplazado? || self.retirado? || self.pi?)
    valor += ' text-muted' if self.retirado?
    return valor
  end

  def name
    "#{user.ci_fullname} en #{section.name}" if (user and section)
  end

  def pi?
    perdida_por_inasistencia?
  end

  def preinscrito_in_process?
    self.enroll_academic_process and self.enroll_academic_process.preinscrito?
  end

  def post_q?
    !post_q.nil?
  end

  def diferido?
    (post_q and post_q.diferido?) ? true : false
  end

  def reparacion?
    (post_q and post_q.reparacion?) ? true : false
  end

  def definitive_q
    aux = post_q
    aux ? aux : final_q
  end

  def definitive_q_value
    definitive_q ? definitive_q.value : nil
  end  

  def final_q
    aux = qualification_by :final
    aux ? aux : nil
  end

  def post_q
    aux = qualification_by [:diferido, :reparacion]
    aux ? aux : nil
  end

  def qualification_by type_q
    self.qualifications.by_type_q(type_q).first
  end

  def definitive_label
    definitive_q ? q_value_to_02i : I18n.t(self.status)
  end

  def type_q_label
    if subject.absoluta?
      'Absoluta'
    else
      definitive_q ? definitive_q.type_q.titleize : 'Final' 
    end
  end

  def final_q_to_02i
    q_value_to_02i final_q
  end

  def final_type_q
    final_q ? final_q.type_q : nil
  end

  def final_q_value 
    q_value final_q
  end

  def post_q_value 
    q_value post_q
  end


  def q_value qualification=definitive_q
    qualification ? qualification.value : nil
  end

  def post_type_q
    post_q ? post_q.type_q : nil
  end

  def post_q_to_02i
    q_value_to_02i post_q
  end

  def post_type_q
    post_q ? post_q.type_q : nil
  end

  def definitive_type_q
    definitive_q ? definitive_q.type_q : :final
  end

  def q_value_to_02i qualification=definitive_q
    qualification ? qualification.value_to_02i : '--'
  end

  def description_q force_final = false
    qualification = force_final ? final_q : definitive_q
    qualification ? (num_to_s qualification) : self.status.to_s.humanize.upcase 
  end

  def num_to_s num = definitive_q_value 
    if pi? or retirado? or (subject and subject.absoluta?) or num.nil? or !(num.is_a? Integer or num.is_a? Float)
      status.humanize.upcase
    else
      numeros = %W(CERO UNO DOS TRES CUATRO CINCO SEIS SIETE OCHO NUEVE DIEZ ONCE DOCE TRECE CATORCE QUINCE DIECISÉIS DIECISIETE DIECIOCHO DIE)
      # dieciséis, diecisiete, dieciocho y diecinueve
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
        'INVÁLIDA'
      end
    end
  end

  def conv_descrip force_final = false # convocados

    data = [self.user.ci, self.user.reverse_name, self.study_plan.code]

    if force_final
      data << I18n.t('aplazado')
      data << I18n.t('final')
      data << self.q_value_to_02i(final_q)
      data << self.description_q(true)
    else
      data << I18n.t(self.status)
      data << I18n.t(self.definitive_type_q)
      data << self.q_value_to_02i #unless self.subject.as_absolute?
      data << self.description_q
    end

    return data

  end

  # RAILS_ADMIN
  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-signature'

    list do
      search_by :custom_search
      fields :period, :section, :student do
        searchable :name
        filterable :name
        sortable :name
      end
      field :definitive_label do
        label 'Definitiva'
      end
      field :status do
        label 'Estado'
      end
      field :type_q_label do
        label 'Tipo'
      end
    end

    edit do
      fields :section, :enroll_academic_process, :status, :qualifications
    end

    export do
      fields :section, :enroll_academic_process, :status, :qualifications, :period, :period_type, :student, :user, :location, :subject
    end
  end  

  private

  def self.import row, fields

    total_newed = total_updated = 0
    no_registred = nil

    # BUSCAR PERIODO
    if row[3]
      row[3].strip!
      row[3].upcase!
    end
    row[3] = fields[:nombre_periodo] if row[3].blank?

    period = Period.find_by_name(row[3]) 

    if period
      # LIMPIAR CI
      if row[0]
        row[0].strip!
        row[0].delete! '^0-9'
      else
        return [0,0,0]
      end

      # LIMPIAR CODIGO ASIGNATURA
      if row[1]
        row[1].strip!
      else
        return [0,0,1]
      end

      subject = Subject.find_by(code: row[1])
      subject ||= Subject.find_by(code: "0#{row[1]}")

      if !subject.nil?
        p "     SUBJECT: #{subject.name}    ".center(300, "U")
        study_plan = StudyPlan.find fields[:study_plan_id]
        if !study_plan.nil?
          p "     STUDY PLAN: #{study_plan.name}    ".center(300, "P")

          escuela = study_plan.school
          # BUSCAR O CREAR PROCESO ACADEMICO:
          academic_process = AcademicProcess.find_or_initialize_by(period_id: period.id, school_id: escuela.id)
          academic_process.default_value_by_import if academic_process.new_record?

          if academic_process.save
            # BUSCAR O CREAR EL CURSOS (PROGRAMACIÓN):
            p "     ACADEMIC PROCESS: #{academic_process.name}    ".center(300, "P")

            if curso = Course.find_or_create_by(subject_id: subject.id, academic_process_id: academic_process.id)

              # BUSCAR O CREAR SECCIÓN
              if row[2]
                row[2].strip!
              else
                return [0,0,2]
              end

              s = Section.find_or_initialize_by(code: row[2], course_id: curso.id)
              s.set_default_values_by_import if s.new_record?

              if s.save
                p "     SECTION: #{s.name}    ".center(300, "S")

                # BUSCAR USUARIO
                user = User.find_by(ci: row[0])
              
                if user and user.student?

                  if stu = user.student
                    p "     STUDENT: #{stu.user_ci}    ".center(300, "E")

                    # BUSCAR O CREAR GRADO
                    grade = Grade.find_by(study_plan_id: study_plan.id, student_id: stu.id)
                    if !grade.nil?
                      p "     GRADE: #{grade.name}    ".center(300, "G")

                      # BUSCAR O CREAR INSCRIPCIÓN PROCESO ACADEMICO:
                      enroll_academic_process = EnrollAcademicProcess.find_or_initialize_by(academic_process_id: academic_process.id, grade_id: grade.id)

                      enroll_academic_process.set_default_values_by_import if enroll_academic_process.new_record?

                      if enroll_academic_process.save
                        p "     ENROLL ACADEMIC PROCESS: #{enroll_academic_process.name}    ".center(300, "E")
                        # BUSCAR O CREAR REGISTRO ACADEMICO
                        academic_record = AcademicRecord.find_or_initialize_by(section_id: s.id, enroll_academic_process_id: enroll_academic_process.id)
                        
                        nuevo = academic_record.new_record?

                        if academic_record.save!
                          p "     EXITO. GUARDADO EL REGISTRO ACADEMICO: #{academic_record.name}    ".center(500, "#")
                          if row[4]
                            row[4].strip! 
                            calificacion_correcta = academic_record.set_status row[4]
                            if calificacion_correcta.eql? true
                              academic_record.reload!
                              if nuevo
                                total_newed = 1
                              else
                                total_updated = 1
                              end
                            else
                              no_registred = 'valor nota'
                            end
                          end
                        else
                          no_registred = 'registro academico'
                        end
                      else
                        no_registred = 'proceso academico'
                      end
                    else
                      no_registred = 'grado'
                    end
                  else
                    no_registred = 'estudiante'
                  end

                else
                  no_registred = 'error'
                end

              else
                no_registred = 2
              end
            else
              no_registred = 1 
            end
          else
            no_registred = 0 # Proceso Academico
          end
        else
          no_registred = 1 # Study Plan
        end
      else
        no_registred = 1
      end
    else
      no_registred = 3
    end
    
    [total_newed, total_updated, no_registred]
  end

end

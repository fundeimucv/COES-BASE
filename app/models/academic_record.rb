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
  def calificar valor

    if valor.eql? 'RT'
      self.status_q = :retirado
      self.type_q = :final
    elsif self.subject and self.subject.absoluta?
      if valor.eql? 'A'
        self.status_q = :aprobado
      else
        self.status_q = :aplazado
      end
      self.type_q = :final
    else
      self.final_q = valor
      
      if self.final_q >= 10
        self.estado = :aprobado
      else
        if self.final_q == 0
          self.type_q = :perdida_por_inasistencia
        else
          self.type_q = :final 
        end
        self.estado = :aplazado
      end
    end
  end

  def student_name_with_retiro
    aux = "#{user.reverse_name}"
    aux += " <div class='badge badge-info'>Retirada</div>" if retirado? 
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

  def final_q_to_02i
    self.final_q.nil? ? nil : sprintf("%02i", self.final_q.to_i)
  end

  def post_q_to_02i
    self.post_q.nil? ? nil : sprintf("%02i", self.post_q.to_i)
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
      fields :period, :section, :student do
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

  private

  def self.import row, fields

    total_newed = total_updated = 0
    no_registred = ''

    # BUSCAR PERIODO
    if row[3]
      row[3].strip!
      row[3].upcase!
    end
    row[3] = fields[:nombre_periodo] if row[3].blank?

    period = Period.find_by_name(row[3]) 
    if period
      # LIMPIAR CI
      row[0].strip!
      row[0].delete! '^0-9'

      # LIMPIAR CODIGO
      row[1].strip!
      row[1].strip! if row[1]

      subject = Subject.find_by(code: row[1])
      subject ||= Subject.find_by(code: "0#{row[1]}")

      if !subject.nil?
        study_plan = StudyPlan.find fields[:study_plan_id]
        if !study_plan.nil?

          escuela = study_plan.school
          # BUSCAR O CREAR PROCESO ACADEMICO:
          proceso_academico = AcademicProcess.find_or_initialize_by(period_id: period.id, school_id: escuela.id)
          proceso_academico.default_value_by_import if proceso_academico.new_record?

          if proceso_academico.save
            # BUSCAR O CREAR EL CURSOS (PROGRAMACIÓN):
            if curso = Course.find_or_create_by(subject_id: subject.id, academic_process_id: proceso_academico.id)

              # BUSCAR O CREAR SECCIÓN
              s = Section.find_or_initialize_by(code: row[2], course_id: curso.id)
              s.set_default_values_by_import if s.new_record?

              if s.save
                # BUSCAR ESTUDIANTE
                
                if estu = Student.find_by_user_ci(row[0])
                  # BUSCAR O CREAR GRADO
                  grado = Grade.find_by(study_plan_id: study_plan.id, student_id: estu.id)
                  if !grado.nil?

                    # BUSCAR O CREAR INSCRIPCIÓN PROCESO ACADEMICO:
                    inscrip_proceso_academico = EnrollAcademicProcess.find_or_initialize_by(academic_process_id: proceso_academico.id, grade_id: grado.id)

                    inscrip_proceso_academico.set_default_values_by_import if inscrip_proceso_academico.new_record?

                    if inscrip_proceso_academico.save
                      # BUSCAR O CREAR REGISTRO ACADEMICO
                      inscrip = AcademicRecord.find_or_initialize_by(section_id: s.id, enroll_academic_process_id: inscrip_proceso_academico.id)
                      nuevo = inscrip.new_record?

                      if row[4] and !row[4].blank?
                        row[4].strip!
                        inscrip.calificar row[4]
                        inscrip.type_q = :final
                      elsif nuevo
                        inscrip.status_q = :sin_calificar
                        inscrip.type_q = :final
                      end

                      if inscrip.save!
                        total_newed += 1
                      else
                        total_updated += 1
                      end

                    else
                      no_registred = "No se pudo inscribir en el proceso #{inscrip_proceso_academico.name[10]}"
                    end
                  else
                    no_registred = "El estudiante #{estu.user_ci} no tiente el plan '#{study_plan.code}' registrado. "
                  end
                else
                  no_registred = "No se encontró el estudiante con ci '#{row[0]}'. Primero registre el estudiante."
                end

              else
                no_registred = "No se pudo crear la sección. '#{row[2]}' incorrecto."
              end

            else
              no_registred = curso.errors.full_messages.to_sentence
            end
          else
            no_registred = proceso_academico.errors.full_messages.to_sentence
          end
        else
          no_registred = "Plan de estudio no encontrado"
        end
      else
        no_registred = "No se encontró la asignatura con código '#{row[1]}'"
      end
    else
      no_registred = "No se encontró el período '#{row[3]}'"
    end
    
    [total_newed, total_updated, no_registred]
  end

end

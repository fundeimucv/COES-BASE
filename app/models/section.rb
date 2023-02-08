class Section < ApplicationRecord
  # SCHEMA:
  # t.string "code"
  # t.integer "capacity"
  # t.bigint "course_id", null: false
  # t.bigint "teacher_id", null: false
  # t.boolean "qualified"
  # t.integer "modality"
  # t.boolean "enabled"

  # ASSOCIATIONS:
  # belongs_to
  belongs_to :course
  belongs_to :teacher, optional: true
  has_one :user, through: :teacher

  # has_one
  has_one :subject, through: :course
  has_one :academic_process, through: :course
  has_one :period, through: :academic_process
  has_one :school, through: :academic_process
  has_one :faculty, through: :school

  # has_many
  has_many :academic_records, dependent: :destroy
  # accepts_nested_attributes_for :academic_records

  has_many :enroll_academic_process, through: :academic_records
  has_many :grades, through: :enroll_academic_process
  has_many :students, through: :grades

  # has_and_belongs_to_namy
  # has_and_belongs_to_many :secondary_teachers, class_name: 'SectionTeacher'

  #ENUMERIZE:
  enum modality: [:nota_final, :equivalencia_externa, :equivalencia_interna, :diferido, :reparacion, :suficiencia]


  # VALIDATIONS:
  validates :code, presence: true
  validates :capacity, presence: true
  validates :course, presence: true
  validates :modality, presence: true


  # FUNCTIONS:
  def set_default_values_by_import
    self.capacity = 50 
    self.modality = :nota_final
  end

  def conv_long
    "U#{self.period.period_type.code}"
  end

  def conv_type
    "#{conv_initial_type}S#{self.period.period_type.code.upcase}"
  end

  def conv_initial_type
    case modality
    when 'nota_final'
      'F'
    when 'equivalencia_externa'
      'EE'
    when 'equivalencia_interna'
      'EI'
    else
      modality.first.upcase if modality
    end
  end


  def number_acta
    "#{self.subject.code.upcase}#{self.code.upcase} #{self.period.name_revert}"
  end

  def name
    "#{self.code}-#{self.course.name}" if self.course
  end

  # RAILS_ADMIN:
  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-list'

    list do
      field :code do
        label 'Id'
      end
      fields :course, :teacher, :qualified#, :enabled
    end

    show do
      field :name do
        label 'Descripción'
      end
      fields :teacher, :academic_records

      field :section_list do
        label 'Listado de seccion'
        formatted_value do
          bindings[:view].render(partial: "/sections/download_options", locals: {section: bindings[:object]})
        end
      end
    end

    edit do
      field :code do
        label 'Identificación'
        html_attributes do
          {:length => 8, :size => 8, :onInput => "$(this).val($(this).val().toUpperCase().replace(/[^A-Za-z0-9]/g,''))"}
        end
      end
      fields :course, :teacher, :modality

      field :capacity do
        html_attributes do
          {:min => 1}
        end
      end

    end

    export do
      fields :code, :subject, :user, :qualified, :modality
    end
  end

  private

  def self.import row, fields

    total_newed = total_updated = 0
    no_registred = ''

    row[1].strip!
    row[1].delete! '^A-Za-z|0-9'

    row[0].strip!
    row[0].delete! '^A-Za-z|0-9'

    subject = Subject.find_by(code: row[1])
    subject ||= Subject.find_by(code: "0#{row[1]}")

    if subject
      # school = School.find (fields[:escuela_id])
      # period = Period.find (fields[:perido_id])
      
      academic_process = AcademicProcess.find fields[:academic_process_id]
      if academic_process
        if curso = Course.find_or_create_by(subject_id: subject.id, academic_process_id: academic_process.id)
          s = Section.find_or_initialize_by(code: row[0], course_id: curso.id)
          nueva = s.new_record?          
          s.set_default_values_by_import if nueva

          if row[3]
            row[3].strip!
            row[3].delete! '^0-9'
            teacher = Teacher.find_by_user_ci(row[3])
            s.teacher_id = teacher.id if teacher
          end

          if s.save
            if nueva
              total_newed = 1
            else
              total_updated = 1
            end
          else
            no_registred = "No se pudo guardar la sección: #{s.errors.full_messages.to_sentence[50]}"
          end
        else
          no_registred = "No se pudo crear el curso de la asignatura '#{subject.code}'"
        end
      else
        no_registred = "Proceso académico #{fields[:academic_process_id]} no encontrado."
      end
    else
      no_registred = "Asignatura #{row[1]} no encontrada."
    end
    [total_newed, total_updated, no_registred]
  end

end

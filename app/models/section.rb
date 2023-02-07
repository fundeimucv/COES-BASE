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

end

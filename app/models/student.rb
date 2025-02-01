# == Schema Information
#
# Table name: students
#
#  active           :boolean          default(TRUE)
#  birth_date       :date
#  disability       :integer
#  grade_title      :string
#  grade_university :string
#  graduate_year    :integer
#  marital_status   :integer
#  nacionality      :integer
#  origin_city      :string
#  origin_country   :string
#  sede             :integer          default("Caracas"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null, primary key
#
# Indexes
#
#  index_students_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Student < ApplicationRecord
  include Userable

  # GLOBALS VARIABLES:
  ESTADOS_CIVILES = {'Soltero/a.': 0, 'Casado/a.': 1, 'Concubinato': 2, 'Divorciado/a.': 3, 'Viudo/a.': 4}
  NACIONALIDAD = {"Venezolano/a": 0, "Extranjero/a": 1, "Venezolano/a. Nacionalizado/a": 2}
  

  DISCAPACIDADES = {'SENSORIAL VISUAL': 0, 'SENSORIAL AUDITIVA': 1, 'MOTORA MIEMBROS INFERIORES': 2, 'MOTORA MIEMBROS SUPERIORES': 3, 'MOTORA AMBOS MIEMBROS': 4, 'OTRO': 5}

  SEDES = ['Caracas', 'Barquisimeto']

  enum nacionality: NACIONALIDAD
  enum disability: DISCAPACIDADES
  enum marital_status: ESTADOS_CIVILES
  enum sede: SEDES

  # HISTORY:
  has_paper_trail on: [:create, :destroy, :update]

  before_create :paper_trail_create
  before_destroy :paper_trail_destroy
  before_update :paper_trail_update

  # ASSOCIATIONS:
  #belons_to
  belongs_to :user
  # accepts_nested_attributes_for :user
  # has_one
  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address
  # has_many
  has_many :grades, dependent: :destroy
  accepts_nested_attributes_for :grades, reject_if: proc { |attributes| attributes['study_plan_id'].blank? }, allow_destroy: true
# creates avatar_attributes=

  has_many :study_plans, through: :grades
  has_many :schools, through: :study_plans
  has_many :admission_types, through: :grades
  has_many :enroll_academic_processes, through: :grades
  has_many :academic_records, through: :enroll_academic_processes

  # VALIDATIONS:
  validates :user, presence: true#, uniqueness: true
  # validates :grades, presence: true
  # validates :sede, presence: true
  # validates :nacionality, presence: true, unless: :new_record?
  # validates :marital_status, presence: true, unless: :new_record?
  # validates :origin_country, presence: true, unless: :new_record?
  # validates :origin_city, presence: true, unless: :new_record?
  # validates :birth_date, presence: true, unless: :new_record?


  # validates :grades, presence: true
  # How to validate if student is not created for assosiation

  # SCOPES:
  scope :custom_search, -> (keyword) { joins(:user).where("users.ci ILIKE '%#{keyword}%' OR users.email ILIKE '%#{keyword}%' OR users.first_name ILIKE '%#{keyword}%' OR users.last_name ILIKE '%#{keyword}%' OR users.number_phone ILIKE '%#{keyword}%'") }

  scope :find_by_user_ci, -> (ci) {joins(:user).where('users.ci': ci).first}

  # CALLBACKS:
  after_destroy :check_user_for_destroy
  
  # HOOKS:
  def check_user_for_destroy
    user_aux = User.find self.user_id
    user_aux.delete if user_aux.without_rol?
  end


  # FUNCTIONS:
  def university_degree
    [grade_title&.titleize, grade_university&.titleize, graduate_year].join(" - ") 
  end

  def roles
    user.roles
  end

  def complete_info?
    !(empty_info? or (user and user.empty_info?) or (address and address.empty_info?))
  end

  def empty_info?
    nacionality.blank? or marital_status.blank? or origin_country.blank? or origin_city.blank? or birth_date.blank?
  end

  def origin_location
    [origin_city, origin_country].join(" - ")
  end

  def self.countries
    require 'json'

    file = File.read("#{Rails.root}/public/countriesToCities.json")

    JSON.parse(file)
  end

  def name
    user.ci_fullname if user
  end

  def user_ci
    self.user.ci if self.user
  end

  # CALLBACKS:
  # HOOKS:

  # IMPORT:

  def self.before_import_find(record)
    if (ci = record[:ci])
      if (user = User.find_by_ci(ci))
        user.update(first_name: record[:first_name], last_name: record[:last_name], email: record[:email])
      else
        user = User.create(ci: record[:ci], first_name: record[:first_name], last_name: record[:last_name], email: record[:email])
      end
      self.user_id = user.id
    end 
    p "ESTOY AQUI 01"


    # if (study_plan = StudyPlan.find_by_code(record[:study_plan_code]) && admission_type = AdmissionType.find_by_code(record[:admission_type_name]))
    #   p "ESTOY AQUIIIIIII"
    #   self.grades.create(study_plan_id: study_plan.id, admission_type_id: admission_type.id)
    # end      
  end

  def after_import_save(record)
    if (study_plan = StudyPlan.find_by_code(record[:study_plan_code]) && admission_type = AdmissionType.find_by_code(record[:admission_type_name]))
      self.grades.create(study_plan_id: study_plan.id, admission_type_id: admission_type.id)
    end  
  end

  # def before_import_save(record)
  #   if (ci = record[:ci])
  #     if (user = User.find_by_ci(ci))
  #       user.update(record[:user])
  #     else
  #       user = User.create(record[:user])
  #     end
  #     self.user_id = user.id
  #   end
  # end

  # def before_import_save(record)
  #     self.user_id = record[:user_id]
  #     self.ci = record[:ci]
  # end
  # def before_import_save(row, map)
  #   self.created_nested_items(row, map)
  # end  

  def self.icon_entity
    'fa-regular fa-user-graduate'
  end  
  
  rails_admin do
    navigation_label 'Gestión de Usuarios'
    navigation_icon 'fa-regular fa-user-graduate'
    weight 4

    edit do
      field :user

      # field :grades do
      #   read_only true
      #   # visible do
      #   #   user = bindings[:view]._current_user
          
      #   #   p "Value: #{value.name}".center 1000, "#"
      #   #   (user&.admin&.authorized_manage? 'Grade' )
      #   #   false
      #   # end
        
      #   active do
      #     user = bindings[:view]._current_user
      #     true
      #   end
      # end

      fields :nacionality, :origin_country, :origin_city, :birth_date, :marital_status, :disability, :grade_title, :grade_university, :graduate_year

    end

    show do
      field :user_personal_data do
        label 'Datos Personales'
        formatted_value do
          bindings[:view].render(partial: 'users/personal_data', locals: {user: bindings[:object].user, student_id: bindings[:object].id})
        end
      end

      field :old_coes do
        label 'Coes v1'
        formatted_value do
          bindings[:view].render(partial: 'students/old_student')
        end          
      end

      field :description_grades do
        label 'Registro Académico'
        formatted_value do
          bindings[:view].render(template: 'students/show', locals: {student: bindings[:object]})
        end
      end
      # fields :user, :grades, :nacionality, :origin_country, :origin_city, :birth_date, :marital_status, :address, :grade_title, :grade_university, :graduate_year, :created_at
    end

    list do
      search_by :custom_search
      checkboxes false
      filters [:schools, :admission_types]
      field :schools do
        label 'Escuelas'
        sticky true
        column_width 120
        searchable :name
        sortable :name
        filterable :name
        sort_reverse true 
        associated_collection_cache_all false
        associated_collection_scope do
          # bindings[:object] & bindings[:controller] are available, but not in scope's block!
          Proc.new { |scope|
            # scoping all Players currently, let's limit them to the team's league
            # Be sure to limit if there are a lot of Players and order them by position
            scope = scope.joins(:schools)
            scope = scope.limit(30) # 'order' does not work here
          }
        end
        pretty_value do
          value.map(&:short_name).to_sentence
        end        
      end

      field :user_image_profile do
        sticky true
        label 'Perfil'

        formatted_value do
          if (bindings[:object].user and bindings[:object].user.profile_picture and bindings[:object].user.profile_picture.attached? and bindings[:object].user.profile_picture.representable?)
            bindings[:view].render(partial: "layouts/set_image", locals: {image: bindings[:object].user.profile_picture, size: '30x30', alt: "foto perfil #{bindings[:object].user.nick_name}"})
          else
            false
          end
        end

      end


      field :user_ci do
        sticky true
        label 'CI'
        pretty_value do
          bindings[:object].user.ci
        end
      end

      # field :user_ci do
      #   label 'Cédula'

      #   sortable do
      #     Proc.new { |scope|
      #       scope = scope.joins(:user).where("users.ci ILIKE '%#{bindings[:object].user_ci}%'").limit(30)
      #     }
      #   end
      #   # sortable "users.ci"
      #   # queryable "users.ci"
      #   # searchable ['users.ci']
      # end

      field :user_last_name do
        label 'Apellidos'
      end
      field :user_first_name do
        label 'Nombres'
      end

      field :address do
        label 'Ubicación'

        filterable [:state, :city, :municipality]
        queryable [:state, :city, :municipality]
        searchable [:state, :city, :municipality]
        
        associated_collection_cache_all false
        associated_collection_scope do
          Proc.new { |scope|
            scope = scope.joins(:address).limit(30)
          }
        end
        pretty_value do
          value&.name
        end
      end

      field :admission_types do
        label 'Admisión'
        # filterable true

        searchable :name
        sortable :name
        filterable :name
        sort_reverse true 
        associated_collection_cache_all false
        associated_collection_scope do
          # bindings[:object] & bindings[:controller] are available, but not in scope's block!
          Proc.new { |scope|
            # scoping all Players currently, let's limit them to the team's league
            # Be sure to limit if there are a lot of Players and order them by position
            scope = scope.joins(:admission_types)
            scope = scope.limit(30) # 'order' does not work here
          }
        end        
      end

      field :study_plans do
        label 'Planes'
        # filterable true

        searchable :code
        sortable :code
        filterable :code
        sort_reverse true 
        associated_collection_cache_all false
        associated_collection_scope do
          # bindings[:object] & bindings[:controller] are available, but not in scope's block!
          Proc.new { |scope|
            # scoping all Players currently, let's limit them to the team's league
            # Be sure to limit if there are a lot of Players and order them by position
            scope = scope.joins(:study_plans)
            scope = scope.limit(30) # 'order' does not work here
          }
        end        
      end      

      field :user_phone do
        label 'Número Telefónico'
      end
      field :user_email do
        label 'Email'
      end      

      field :created_at

      # field :roles do
      #   label 'Roles'
      # end

      field :link_to_reset_password do
        label 'Opciones'
        visible do
          user = bindings[:view]._current_user
          user&.admin&.authorized_manage? 'Student'
        end
      end

    end

    export do
      fields :user, :nacionality, :origin_country, :sede, :origin_city, :birth_date, :marital_status, :address, :created_at

      field :admission_types do
        label 'Tipos de Admisión'

        associated_collection_cache_all false
        associated_collection_scope do
          # bindings[:object] & bindings[:controller] are available, but not in scope's block!
          Proc.new { |scope|
            # scoping all Players currently, let's limit them to the team's league
            # Be sure to limit if there are a lot of Players and order them by position
            scope = scope.joins(:admission_types)
            scope = scope.limit(30) # 'order' does not work here
          }
        end        
      end

      field :study_plans do
        label 'Planes de Estudio'
        filterable :code

        associated_collection_cache_all false
        associated_collection_scope do
          # bindings[:object] & bindings[:controller] are available, but not in scope's block!
          Proc.new { |scope|
            # scoping all Players currently, let's limit them to the team's league
            # Be sure to limit if there are a lot of Players and order them by position
            scope = scope.joins(:study_plans)
            scope = scope.limit(30) # 'order' does not work here
          }
        end        
      end            
    end

    import do
      field :ci
      field :email
      field :first_name
      field :last_name
      field :study_plan_code
      field :admission_type_name

      # mapping_key_list ['user[ci]', 'user[email]', 'user[first_name]','user[last_name]']
      # mapping_key_list ['ci', 'email', 'first_name','last_name']
    end

  end

  def user_last_name
    user.last_name if user
  end
  def user_first_name
    user.first_name if user
  end 
  def user_phone
    user.number_phone if user
  end 
  def user_email
    user.email if user
  end
  def address_short
    address&.state_and_city if address
  end
  def grade_admission_type
    grades.map{|g| g.admission_type.name if g.admission_type}.to_sentence
  end

  def self.import row, fields
    total_newed = total_updated = 0
    no_registred = nil

    # Cédula de Identidad
    if row[0]
      row[0].strip!
      row[0].delete! '^0-9'
    else
      return [0,0,0]
    end
    
    usuario = User.find_or_initialize_by(ci: row[0])
    
    # Email
    row[1] = nil if fields[:console]&.eql? true
    if row[1]
      row[1].strip!
      usuario.email = row[1].remove("mailto:")
    elsif usuario.email.blank?
      usuario.email = "#{usuario.ci}@mailinator.com"
    # else
    #   return [0,0,1]
    end

    # Nombres
    if row[2]
      row[2].strip!
      usuario.first_name = row[2]
    else
      return [0,0,2]
    end

    # Apellidos
    if row[3]
      row[3].strip!
      usuario.last_name = row[3] if row[3]
    else
      return [0,0,3]
    end

    # Sexo
    if row[4]
      row[4].strip!
      row[4].delete! '^A-Za-z'
      row[4] = :Masculino if row[4][0].upcase.eql? 'M'
      row[4] = :Femenino if row[4][0].upcase.eql? 'F'
      usuario.sex = row[4] 
    end

    # Numero Telefónico
    usuario.number_phone = row[5] if row[5]

    usuario.password = usuario.ci if usuario.password.blank?
    usuario.password_confirmation = usuario.ci if usuario.password_confirmation.blank?

    if usuario.save!(validate: false)
      estudiante = Student.find_or_initialize_by(user_id: usuario.id)

      # estudiante.birth_date = row[8] if row[8]
      # p "    Estudiante: #{estudiante.attributes.to_a.to_sentence}    ".center(600, "E")

      new_grade = !estudiante.grades.where(study_plan_id: fields[:study_plan_id]).any?
      grado = estudiante.grades.find_or_initialize_by(study_plan_id: fields[:study_plan_id])
      grado.admission_type_id = fields[:admission_type_id]

      if estudiante.save!
        # grado = Grade.find_or_initialize_by(student_id: estudiante.id, study_plan_id: fields[:study_plan_id])

        if row[6]
          # Proceso Academico de Ingreso
          year, type = row[6].split('-')
          period_type = PeriodType.find_by_code(type)
          modality = type[2]
          period = Period.find_or_create_by(year: year, period_type_id: period_type.id)

          modality = AcademicProcess.letter_to_modality modality
          academic_process = AcademicProcess.where(period_id: period.id, modality: modality, school_id: grado.school.id).first

          if academic_process.nil?
            academic_process = AcademicProcess.create(period_id: period.id, modality: modality, school_id: grado.school.id, max_credits: 24, max_subjects: 5)
          end

          grado.start_process_id = academic_process&.id

        elsif fields[:start_process_id]
          grado.start_process_id = fields[:start_process_id]
        end

        if row[7].present? and !row[7].blank?
          # Tipo de Admisión
          if aux_admission = AdmissionType.find_by_code(row[7])
            grado.admission_type_id = aux_admission&.id
          end
        elsif fields[:admission_type_id]
          grado.admission_type_id = fields[:admission_type_id]
        else
          grado.admission_type_id = AdmissionType.first.id
        end
        
        # Año de Admisión
        p "     Row8: #{row[8]}           ".center(1000, "R")

        grado.admission_year = (row[8].present? and !row[8].blank? and (row[8].is_a? Integer)) ? row[8].to_i : fields[:admission_year]


        # print "AT: <#{grado.admission_type_id}>"

        if grado.save
          if new_grade
            total_newed = 1
          else
            total_updated = 1
          end
        else
          no_registred = row
        end
      else
        no_registred = row
      end
    else
      no_registred = row
    end

    [total_newed, total_updated, no_registred]
  end

  private


    def paper_trail_update
      # changed_fields = self.changes.keys - ['created_at', 'updated_at']
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      # self.paper_trail_event = "¡#{object} actualizado en #{changed_fields.to_sentence}"
      self.paper_trail_event = "¡#{object} actualizado!"
    end  

    def paper_trail_create
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡#{object} registrado!"
    end  

    def paper_trail_destroy
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡Estudiante eliminado!"
    end

end

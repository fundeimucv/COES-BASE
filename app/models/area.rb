# == Schema Information
#
# Table name: areas
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#
# Indexes
#
#  index_areas_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Area < ApplicationRecord  
  # HISTORY:
  has_paper_trail on: [:create, :destroy, :update]

  before_create :paper_trail_create
  before_destroy :paper_trail_destroy
  before_update :paper_trail_update

  # ASSOCITATIONS:
  belongs_to :school
  has_and_belongs_to_many :departaments
  # has_many :schools, through: :departaments

  has_many :subjects, dependent: :restrict_with_error
  has_many :sections, through: :subjects
  has_many :academic_records, through: :sections
  # accepts_nested_attributes_for :subjects

  # VALIDATIONS:
  validates :school, presence: true
  # validates :name, presence: true, uniqueness: {case_sensitive: false}
  
  validates_uniqueness_of :name, scope: [:school_id], message: 'de la cátedra ya creado en la Escuela', field_name: false
  validates_with SameSchoolToAreaValidator, field_name: false

  # SCOPES:
  # scope :main, -> {where(departament_id: nil)}
  # scope :catedras, -> {where.not(departament_id: nil)}
  scope :names, -> {select(:name).map{|ar| ar.name}}

  # CALLBACKS:
  before_save :clean_name

  # HOOKS:
  def clean_name
    self.name.strip!
    self.name.upcase!
  end

  # FUNCTIONS:
  def name_with_school
    "#{name} (#{school&.name})"
  end

  def full_description
    "#{name}: #{departaments.map{|de| de.desc}.to_sentence}"
  end

  def description
    "#{self.id}: #{self.name}"
  end

  def total_subjects
    subjects.count
  end

  rails_admin do
    visible do
      bindings[:controller].current_user&.admin?
    end
    navigation_label 'Config General'
    navigation_icon 'fa-regular fa-book-open'
    weight 1
    
    list do
      sort_by :name
      checkboxes false
      field :school do
        pretty_value do
          value&.short_name
        end
      end
      field :name
      field :departaments
      field :total_subjects do
        label 'Total Asignaturas'
      end
    end
    show do
      field :school
      field :name
      field :departaments
      field :subjects do
        pretty_value do
          bindings[:view].render(template: '/subjects/index', locals: {area_id: bindings[:object].id, subjects: bindings[:object].subjects.order(code: :asc)})
        end
      end
    end 

    edit do
      field :school do
        inline_add false
        inline_edit false
        partial 'school/custom_school_id_field'
      end
      field :name do
        html_attributes do
          {:onInput => "$(this).val($(this).val().toUpperCase())"}
        end         
      end

      field :departaments do
        inline_edit false
      end

    end 

    modal do
      field :name
      exclude_fields :departaments
    end


    export do
      fields :name, :departaments
    end

  end

  
    def departaments_school_id
      departaments.pluck(:school_id).first
    end
  protected

  private


    def paper_trail_update
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡#{object} actualizada!"
    end  

    def paper_trail_create
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡#{object} registrada!"
    end  

    def paper_trail_destroy
      object = I18n.t("activerecord.models.#{self.model_name.param_key}.one")
      self.paper_trail_event = "¡#{object} eliminada!"
    end  

end

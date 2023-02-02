class Subject < ApplicationRecord
  # SCHEMA:
  # t.string "code", null: false
  # t.string "name", null: false
  # t.boolean "active", default: true
  # t.integer "unit_credits", default: 24, null: false
  # t.integer "ordinal", default: 0, null: false
  # t.integer "qualification_type"
  # t.integer "modality"
  # t.bigint "area_id", null: false  
  # t.boolean "force_absolute", default: false  

  # ASSOCIATIONS:
  belongs_to :area
  has_one :school, through: :area

  has_many :courses, dependent: :destroy

  # ENUMS:
  enum qualification_type: [:numerica, :absoluta]
  enum modality: [:obligatoria, :electiva, :optativa] 

  # VALIDATIONS:
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :ordinal, presence: true
  validates :modality, presence: true
  validates :qualification_type, presence: true
  validates :unit_credits, presence: true
  validates :area, presence: true

  # SCOPES: 
  scope :custom_search, -> (keyword) {joins([:area]).where("name LIKE ? or code LIKE ? or area.name LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")} 

  # HOST:
  def self.clean_values
    self.name.delete! '^0-9|^A-Za-z|áÁÄäËëÉéÍÏïíÓóÖöÚúÜüñÑ '
    self.name.strip!
    self.code.delete! '^0-9|^A-Za-z|áÁÄäËëÉéÍÏïíÓóÖöÚúÜüñÑ'
    self.code.strip!    
  end


  # FUNCTIONS: 
  def as_absolute?
    self.absoluta? or self.force_absolute?
  end

  def desc
    "#{code}: #{name}"
  end

  def conv_header

    data = ["N°", "CÉDULA DE IDENTIDAD", "APELLIDOS Y NOMBRES", "COD. PLAN", "CALIF. DESCR.", "TIPO", "CALIF. EN LETRAS"]

    data.insert(6, "CALIF. NUM.") unless self.as_absolute?

    return data

  end



  def modality_initial_letter
    case modality
    when 'obligatoria'
      'OB'
    when 'electiva'
      'E'
    when 'optativa'
      'OP'
    when 'proyecto'
      'P'
    end      
  end

  rails_admin do
    navigation_label 'Gestión Académica'
    navigation_icon 'fa-regular fa-book'

    list do
      search_by :custom_search

      field :code do
        searchable true
      end

      field :name do
        searchable true
      end

      field :area do
        searchable :name
      end

      fields :unit_credits, :ordinal, :qualification_type, :modality, :created_at, :updated_at
    end

    show do
      fields :area, :code, :name, :unit_credits, :ordinal, :qualification_type, :modality, :created_at, :updated_at
    end

    edit do
      field :area
      field :code do
        html_attributes do
          {length: 20, size: 20, onInput: "$(this).val($(this).val().toUpperCase().replace(/[^A-Za-z0-9]/g,''))"}
        end  
      end
      field :name do
        html_attributes do
          {:onInput => "$(this).val($(this).val().toUpperCase())"}
        end  
      end      
      fields :modality, :unit_credits

      field :ordinal do
        html_attributes do
          {min: 0, max: 20}
        end
        help 'Semestre o año en que se ubica la asignatura'
      end

      field :qualification_type do
        help 'Parcial3 equivale a asignatura con 3 calificaciones parciales'
      end

    end

    export do
      fields :code, :name, :area, :unit_credits, :ordinal, :qualification_type, :modality

    end
  end

end

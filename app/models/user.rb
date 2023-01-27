class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # SCHEMA:
  # t.string "email", default: "", null: false
  # t.string "ci", null: false
  # t.string "encrypted_password", default: "", null: false
  # t.string "name"
  # t.string "last_name"
  # t.string "number_phone"
  # t.integer "sex"
  # t.datetime "remember_created_at"
  # t.integer "sign_in_count", default: 0, null: false
  # t.datetime "current_sign_in_at"
  # t.datetime "last_sign_in_at"
  # t.string "current_sign_in_ip"
  # t.string "last_sign_in_ip"  

  # ENUMERIZE:
  enum sex: [:femenino, :masculino]

  # DEVISE MODULES:
  devise :database_authenticatable, :registerable, :rememberable

  # ASSOCIATIONS:
  has_one :admin, inverse_of: :user, foreign_key: :user_id, dependent: :destroy
  accepts_nested_attributes_for :admin
  
  has_one :student, inverse_of: :user, foreign_key: :user_id, dependent: :destroy
  accepts_nested_attributes_for :student

  has_one :teacher, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :teacher

  has_one_attached :picture_profile do |attachable|
    attachable.variant :icon, resize_to_limit: [35, 35]
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  def picture_profile_as_thumb
    picture_profile.variant(resize_to_limit: [100, 100]).processed
  end

  attr_accessor :remove_picture_profile
  after_save { picture_profile.purge if remove_picture_profile.eql? '1' } 

  has_one_attached :image_ci do |attachable|
    attachable.variant :thumb, resize_to_limit: [100,100]
  end

  attr_accessor :remove_image_ci
  after_save { image_ci.purge if remove_image_ci.eql? '1' } 

  attr_accessor :allow_blank_password

  # VALIDATIONS:
  validates :ci, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true#, unless: :new_record?
  validates :last_name, presence: true#, unless: :new_record?

  # validates :number_phone, presence: true, unless: :new_record?
  # validates :sex, presence: true, unless: :new_record?
  
  # validates :password, presence: true, confirmation: true
  # validates :password_confirmation, presence: true
  # attr_accessor :password_confirmation

  # SCOPES:
  scope :my_search, -> (keyword) {where("ci ILIKE '%#{keyword}%' OR email ILIKE '%#{keyword}%' OR first_name ILIKE '%#{keyword}%' OR last_name ILIKE '%#{keyword}%' OR number_phone ILIKE '%#{keyword}%'") }

  # CALLBACKS:
  before_save :upcases
  before_save :set_default_password, if: :new_record?

  # HOOKS:
  def after_import_save(record)
    # called on the model after it is saved
    p "<   #{record}   >".center(200, "-") 
  end


  def set_default_values
    self.upcases
    self.set_ci_to_i
    self.set_default_password
  end

  def without_rol?
    (self.how_many_roles? == 0)
  end

  def how_many_roles?
    aux = 0
    aux += 1 if admin?
    aux += 1 if student?
    aux += 1 if teacher?    
    return aux
  end

  def upcases
    self.first_name.upcase!
    self.last_name.upcase!
  end

  def set_default_password
    self.password ||= self.ci #if self.password.blank?
  end

  def set_ci_to_i
    self.ci = self.ci.to_i.to_s if !self.ci.blank?
  end 

  # INTENTOS FALLIDOS REGEXP, AHORA INCLUYE Ñ PERO FALTA EL ACENTO
  # regexp_español = "/^[a-zA-ZÀ-ÿ\u00f1\u00d1]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]+$/g"
  # regexp_español2 = "/[^A-Z\u00e0-\u00fc| ]/g"
  # regexp_español3 = "/[^a-zA-Z\u00C0-\u017F| ]/g" 
  # regexp_español4 = "/[^a-zA-ZÀ-ÿ\u00f1\u00d1 ]+(\s*[a-zA-ZÀ-ÿ\u00f1\u00d1]*)*[a-zA-ZÀ-ÿ\u00f1\u00d1]+$/g"
  # regexp_español_ori = "/[^A-Za-z| ]/g"
  # Para Probar: .replace(/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F-\x9F]/g, '');

  regexp_español3 = "/[^a-zA-Z\u00C1\u00C9\u00CD\u00D3\u00DA\u00DC\u00E1\u00E9\u00ED\u00F3\u00FA\u00FC| ]/g" #√

  # RAILS_ADMIN:
  rails_admin do
    navigation_icon 'fa-regular fa-user'
    # def self.full_name
    #   "#{name} #{last_name}"
    # end

    edit do
      field :ci do
        html_attributes do
          {:length => 8, :size => 8, :onInput => "$(this).val($(this).val().toUpperCase().replace(/[^0-9]/g,''))"}
        end
      end
      field :email

      field :first_name do
        formatted_value do
          value.to_s.upcase
        end
        html_attributes do
          {:onInput => "$(this).val($(this).val().toUpperCase().replace(#{regexp_español3},''))"}
        end  
      end

      field :last_name do
        formatted_value do
          value.to_s.upcase
        end
        html_attributes do
          {:onInput => "$(this).val($(this).val().toUpperCase().replace(#{regexp_español3},''))"}
        end  
      end

      field :password do
        read_only true
        aux = 'Si está creando un nuevo usuario, la contraseña será igual a la cédula de identidad. Posteriormente, el usuario mismo podrá cambiarla al iniciar sesión. Si está editando un usuario ya creado, podrá autogestionar su contraseña mediante la opción "olvidé contraseña" del inicio de sesión.'
        help aux

      end
      field :number_phone do
        html_attributes do
          {length: 8, size: 8, onInput: "$(this).val($(this).val().toUpperCase().replace(/[^0-9]/g,''))"}
        end
      end

      field :sex
      # field :sex do
      #   html_attributes do
      #     {:type => :radio }
      #   end        
      # end

      field :picture_profile, :active_storage do
        label 'Imagen de Perfil'
        delete_method :remove_picture_profile
      end
      field :image_ci, :active_storage do
        label 'Imagen CI'
        delete_method :remove_image_ci
      end 
    end

    show do
      # field :picture_profile, :active_storage  do

        # formatted_value do
        #   bindings[:view].tag(:img, { :src => bindings[:object].picture_profile }) << value
        # end
        # formatted_value do
        #   bindings[:view].render(partial: "rails_admin/main/image", locals: {object: bindings[:object]})
        # end
      # end
      field :picture_profile, :active_storage 
      field :image_ci, :active_storage 
      field :ci
      field :email
      field :first_name
      field :last_name
      field :number_phone
      field :sex
      field :password

    end

    list do
      items_per_page 10
      search_by :my_search #[:email, :first_name, :last_name, :ci]
      field :ci
      field :email
      field :first_name
      field :last_name
      field :number_phone
      field :sex
      field :picture_profile
    end

    export do
      field :ci 
      field :email 
      field :first_name 
      field :last_name 
      field :number_phone 
      field :sex
    end

    import do
      fields :ci, :email, :first_name, :last_name#, :student, :teacher
      mapping_key :ci 

    end

  end

  #FUNCTIONS:

  def admin?
    self.admin.nil? ? false : true
  end

  def student?
    self.student.nil? ? false : true
  end

  def teacher?
    self.teacher.nil? ? false : true
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def description
    "#{self.ci} (#{self.email}): #{self.first_name} #{self.last_name}"
  end

  def ci_fullname
    "#{ci}: #{full_name}"
  end

  def name
    description
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

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
  enum sex: [:masculino, :femenino]

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


  #VALIDATIONS
  validates :ci, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true#, unless: :new_record?
  validates :last_name, presence: true#, unless: :new_record?
  validates :number_phone, presence: true, unless: :new_record?
  validates :sex, presence: true, unless: :new_record?

  # RAILS_ADMIN:

  rails_admin do
    edit do
      fields :ci, :email, :name, :last_name, :number_phone, :sex, :password
      field :picture_profile, :active_storage do
        label 'Adjunto'
        delete_method :remove_picture_profile
      end
      field :image_ci, :active_storage do
        label 'Adjunto'
        delete_method :remove_image_ci
      end      
    end

    show do
      field :picture_profile, :active_storage  do
        label 'Perfil'
        formatted_value do
          bindings[:view].render(partial: "rails_admin/main/image", locals: {object: bindings[:object]})
        end        
      end
      field :image_ci, :active_storage  do
        label 'Perfil'
      end      
      fields :ci, :email, :name, :last_name, :number_phone, :sex, :password

    end

    list do
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
end

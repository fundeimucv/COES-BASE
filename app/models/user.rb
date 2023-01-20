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

  attr_accessor :allow_blank_password

  # VALIDATIONS:
  validates :ci, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true#, unless: :new_record?
  validates :last_name, presence: true#, unless: :new_record?
  validates :number_phone, presence: true, unless: :new_record?
  validates :sex, presence: true, unless: :new_record?


  # FUNCTIONS:

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

  # RAILS_ADMIN:

  rails_admin do
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
      fields :first_name, :last_name do
        formatted_value do
          value.to_s.upcase
        end
        html_attributes do
          {:onInput => "$(this).val($(this).val().toUpperCase().replace(/[^A-Za-z| ]/g,''))"}
        end  
      end
      field :number_phone do
        html_attributes do
          {length: 8, size: 8, onInput: "$(this).val($(this).val().toUpperCase().replace(/[^0-9]/g,''))"}
        end
      end

      field :sex do
        html_attributes do
          {:type => :radio }
        end        
      end

      field :password

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
      fields :ci, :email, :first_name, :last_name, :number_phone, :sex, :password

    end

    list do
      search_by [:email, :first_name, :last_name, :ci]
      fields :ci, :email, :first_name, :last_name, :number_phone, :sex, :picture_profile
    end

    export do
      fields :ci, :email, :first_name, :last_name, :number_phone, :sex
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

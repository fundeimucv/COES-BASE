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
  has_one :admin, inverse_of: :user, foreign_key: :user_id
  accepts_nested_attributes_for :admin
  
  has_one :student, inverse_of: :user, foreign_key: :user_id
  accepts_nested_attributes_for :student

  has_one :teacher#, inverse_of: :user
  accepts_nested_attributes_for :teacher

  #VALIDATIONS
  validates :ci, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true#, unless: :new_record?
  validates :last_name, presence: true#, unless: :new_record?
  validates :number_phone, presence: true, unless: :new_record?
  validates :sex, presence: true, unless: :new_record?
  validates :password, presence: true

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

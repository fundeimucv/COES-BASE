class Student < ApplicationRecord

  # SCHEMA:
  # t.boolean "active", default: true
  # t.integer "disability"
  # t.integer "nacionality"
  # t.integer "marital_status"
  # t.string "origin_country"
  # t.string "origin_city"
  # t.date "birth_date"  

  # GLOBALS VARIABLES:
  ESTADOS_CIVILES = ['soltero/a', 'casado/a', 'concubinato', 'divorciado/a', 'viudo/a']
  NACIONALIDAD = ['venezolano/a', 'venezolano/a vacionalizado/a', 'extranjero/a']

  DISCAPACIDADES = ['NINGUNA', 'SENSORIAL VISUAL', 'SENSORIAL AUDITIVA', 'MOTORA MIEMBROS INFERIORES', 'MOTORA MIEMBROS SUPERIORES', 'MOTORA AMBOS MIEMBROS']

  enum nacionality: NACIONALIDAD
  enum disability: DISCAPACIDADES
  enum marital_status: ESTADOS_CIVILES

  # ASSOCIATIONS:
  #belons_to
  belongs_to :user
  # has_one
  has_one :location
  # has_many
  has_many :grades

  # validations
  validates :marital_status, presence: true, unless: :new_record?
  validates :origin_country, presence: true, unless: :new_record?
  validates :origin_city, presence: true, unless: :new_record?
  validates :birth_date, presence: true, unless: :new_record?
  # validates :location, presence: true, unless: :new_record?
  # How to validate if student is not created for assosiation


end

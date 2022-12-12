class Student < ApplicationRecord
  # SCHEMA:
  # t.boolean "active", default: true
  # t.integer "disability"
  # t.integer "nacionality"
  # t.integer "marital_status"
  # t.string "origin_country"
  # t.string "origin_city"
  # t.date "birth_date"  

  # ASSOCIATIONS:
  #belons_to
  belongs_to :user

  # has_many
  has_many :grades

  # validations

end

class Location < ApplicationRecord
  # SCHEMA:
  # t.references :student, null: false, foreign_key: true
  # t.string :state
  # t.string :municipality
  # t.string :city
  # t.string :sector
  # t.string :street
  # t.integer :house_type
  # t.string :house_name

  # ENUMERIZE:
  enum house_type: [:casa, :quinta, :apartamento]

  #ASSOCIATIONS:  
  belongs_to :student, primary_key: :user_id

  def description
    "#{city} - #{state}: #{municipality}. #{sector}: #{street}, #{house_type} #{house_name}"
  end

  # VALIDATIONS:
  validates :student, presence: true
  validates :state, presence: true
  validates :municipality, presence: true
  validates :city, presence: true
  validates :sector, presence: true
  validates :street, presence: true
  validates :house_type, presence: true
  validates :house_name, presence: true


  rails_admin do
    export do
      exclude_fields :id, :created_at, :updated_at
    end
  end

end

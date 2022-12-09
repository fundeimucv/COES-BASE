class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # DEVISE MODULES:
  devise :database_authenticatable, :registerable, :rememberable

  # ASSOCIATIONS:
  has_one :admin#, inverse_of: :user
  accepts_nested_attributes_for :admin
  
  has_one :student#, inverse_of: :user, foreign_key: :user_id
  accepts_nested_attributes_for :student

  has_one :teacher#, inverse_of: :user
  accepts_nested_attributes_for :teacher

end

class Student < ApplicationRecord
  belongs_to :user

  has_many :grades

end

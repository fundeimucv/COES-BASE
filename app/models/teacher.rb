class Teacher < ApplicationRecord
  belongs_to :user
  belongs_to :area
  has_one_and_belongs_to_many :secondary_teachers class_name: 'SectionTeacher'

end

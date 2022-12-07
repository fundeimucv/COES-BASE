class Section < ApplicationRecord
  belongs_to :course
  belongs_to :teacher

  has_one_and_belongs_to_many :secondary_teachers class_name: 'SectionTeacher'
end

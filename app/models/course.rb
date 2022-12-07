class Course < ApplicationRecord
  belongs_to :academic_process
  belongs_to :subject
end

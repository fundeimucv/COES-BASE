class AcademicRecord < ApplicationRecord
  belongs_to :section
  belongs_to :enroll_academic_process
end

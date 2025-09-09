module AcademicProcessable
  extend ActiveSupport::Concern

  def process_name
    academic_process&.process_name
  end  

end

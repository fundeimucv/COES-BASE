class SamePeriodValidator < ActiveModel::Validator
  def validate(record)
    if diferent_period(record)
      record.errors.add "No es posible inscribir una asignatura ofertada en otro periodo, el periodo es #{record.enroll_academic_process.process_name} ", "y la asignatura es del periodo #{record.course.process_name} ."
    end
  end

  private
    def diferent_period(record)
      not (record.section.academic_process.id.eql? record.enroll_academic_process.academic_process.id)
    end
end

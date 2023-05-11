class SameSubjectInPeriodValidator < ActiveModel::Validator
  def validate(record)
    if same_course_in_period(record)
      record.errors.add "Está seleccionando #{record.subject.name.upcase} que ya fue inscrita", "en el Período #{record.enroll_academic_process.period.name}. Ponga atención en la selección."
    end
  end

  private
    def same_course_in_period(record)
      subject_ids = record.enroll_academic_process.subjects.ids
      subject_ids.include? record.subject.id
    end
end

class ApprovedAndEnrollingValidator < ActiveModel::Validator
  def validate(record)
    if approved_and_enrolling(record)
      record.errors.add "Está seleccionando #{record.subject.name.upcase} que ya fue aprobada", "Ponga atención en la selección."
    end
  end

  private
    def approved_and_enrolling(record)
      record.enroll_academic_process.enrolling? and (record.grade.subjects_approved_ids.include? record.subject.id)
    end
end

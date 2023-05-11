class SameSchoolValidator < ActiveModel::Validator
  def validate(record)
    if same_school(record)
      record.errors.add "Está seleccionando una sección de #{record.section.school.code} y", "el Procesos Académico es de #{record.enroll_academic_process.school.code}. Ponga atención en la selección."
    end
  end

  private
    def same_school(record)
      pci = record.course.offer_as_pci.eql? true
      !(pci and record.section.school.id.eql? record.enroll_academic_process.school.id)
    end
end

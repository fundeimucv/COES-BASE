class SameSchoolInSubjectValidator < ActiveModel::Validator
  def validate(record)
    if diferent_school(record)
      record.errors.add "No es posible registrar la asignatura en areas y/o departamentos", "no pertenecientes a la escuela"
    end
  end

  private
    def diferent_school(record)
      !(record.school_id&.eql? record.departament&.school_id and record.school_id&.eql? record.area&.school_id)
    end
end

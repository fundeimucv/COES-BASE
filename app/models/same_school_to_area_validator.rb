class SameSchoolToAreaValidator < ActiveModel::Validator
    def validate(record)
        school_ids = record.departaments.map(&:school_id).uniq.count
        record.errors.add "No es posible registrar una cátedra para más de una", " Escuela" if school_ids > 1
    end
end

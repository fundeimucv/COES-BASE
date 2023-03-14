class NestedDependencyValidator < ActiveModel::Validator
  def validate(record)
    if nested_dependency(record)
      record.errors.add "Prelación #{record.id}", 'anidada.'
    end
  end

  private
    def nested_dependency(record)
      p "    #{record.to_s}      ".center(500, "%")
      (record.subject_parent_id.eql? record.subject_dependent_id) or
      record.subject_parent.full_dependency_tree_ids.include? record.subject_dependent_id
    end
end

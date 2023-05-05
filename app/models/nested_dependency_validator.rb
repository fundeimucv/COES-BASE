class NestedDependencyValidator < ActiveModel::Validator
  def validate(record)
    if nested_dependency(record)
      record.errors.add "Prelación #{record.id}", 'anidada.'
    end
  end

  private
    # def nested_dependency(record)
    #   depend_tree = record.prelate_subject.depend_tree
    #   depend_tree = [depend_tree] if depend_tree.is_a? Integer
    #   prelate_tree = record.prelate_subject.prelate_tree
    #   prelate_tree = [prelate_tree] if prelate_tree.is_a? Integer      
    #   p "    TREE: #{depend_tree}      ".center(500, "%")
    #   p "    depend_subject_id: #{record.prelate_subject_id}      ".center(500, "%")
    #   1/0
    #   (record.prelate_subject_id.eql? record.depend_subject_id) or
    #   (depend_tree and depend_tree.include? record.prelate_subject_id) or (prelate_tree and prelate_tree.include? record.prelate_subject_id)
    # end

    def nested_dependency(record)
      tree = record.prelate_subject.full_dependency_tree_ids
      p "    TREE: #{tree}      ".center(500, "%")
      p "    depend_subject_id: #{record.prelate_subject_id}      ".center(500, "%")
      (record.prelate_subject_id.eql? record.depend_subject_id) or
      (tree.include? record.depend_subject_id)
    end    
end

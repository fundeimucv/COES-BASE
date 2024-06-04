module Totalizable

  def total_inscritos
    self.academic_records.count
  end

end

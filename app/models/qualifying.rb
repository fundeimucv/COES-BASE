module Qualifying

    def evaluation
        (self.is_a? Qualification) ? type_q : partial
    end
    def label_qualification
        aux = approved? ? 'bg-success' : 'bg-warning text-dark' 
        "<span class='text-center badge #{aux}' data-bs-toggle='tooltip' rel='tooltip' data-bs-original-title='#{evaluation&.titleize} #{%{👍🏽} if approved?}'>#{value_to_02i}</span>"
    end
    def value_to_02i
      if !value.blank?
        if value.is_a? Integer
          sprintf("%02i", value)
        else
          sprintf("%02.2f", value)
        end
      else
        nil
      end
    end

    def is_valid_numeric_value?
      !value.blank? and (value.is_a? Integer or value.is_a? Float or value.is_a? BigDecimal)
    end

  def approved?
    if is_valid_numeric_value?
      value.to_i >= 10
    else
      false
    end
  end

  def repproved?
    if is_valid_numeric_value?
      value.to_i < 10
    else
      false
    end
  end  

  # def label_numbery_total
  #   aux = ApplicationController.helpers.label_status_with_tooltip('bg-info me-1', total_academic_records, 'Inscritos')
  #   aux += ApplicationController.helpers.label_status_with_tooltip('bg-secondary me-1', total_sc, 'Sin Calificar')
  #   aux += ApplicationController.helpers.label_status_with_tooltip('bg-success me-1', total_aprobados, 'Aprobados')
  #   aux += ApplicationController.helpers.label_status_with_tooltip('bg-danger me-1', total_aplazados, 'Aplazados')
  #   aux += ApplicationController.helpers.label_status_with_tooltip('bg-secondary me-1', total_retirados, 'Retirdos')
  #   aux += ApplicationController.helpers.label_status_with_tooltip('bg-danger', total_pi, 'PI')  
  # end
end

module Numerizable

    def numbers
        "Efi: #{self.efficiency}, Prom. Ponderado: #{self.weighted_average}, Prom. Simple: #{self.simple_average}"
        # redear una tabla descripción. OJO Sí es posible estandarizar
      end

    def efficiency_desc
        efficiency.nil? ? '--' : (efficiency).round(2)
    end

    def simple_average_desc
        simple_average.nil? ? '--' : (simple_average).round(2)
    end

    def weighted_average_desc
        weighted_average.nil? ? '--' : (weighted_average).round(2)
    end
    
    def calculate_efficiency
        cursados = self.total_subjects_coursed
        aprobados = self.total_subjects_approved
        if cursados < 0 or aprobados < 0
          0.0
        elsif cursados == 0 or (cursados > 0 and aprobados >= cursados)
          1.0
        else
          (aprobados.to_f/cursados.to_f).round(4)
        end
    end
      
    def calculate_average periods_ids = nil
        if periods_ids
          aux = academic_records.of_periods(periods_ids).promedio
        else
          aux = academic_records.promedio
        end
    
        (aux&.is_a? BigDecimal) ? aux.to_f.round(4) : self.simple_average
    end

    def calculate_average_approved
        aux = self.academic_records.promedio_approved
        (aux and aux.is_a? BigDecimal) ? aux.round(4) : 0.0
    end    

    def calculate_weighted_average periods_ids = nil
        if periods_ids
            aux = academic_records.of_periods(periods_ids).weighted_average
        else
            aux = academic_records.weighted_average
        end
        total_coursed_credits = self.total_credits_coursed_not_equivalence

        (total_coursed_credits > 0 and aux) ? (aux.to_f/total_coursed_credits.to_f).round(4) : self.weighted_average
    end

    def calculate_weighted_average_approved
        aux = self.weighted_average_approved
        creadits_approved = self.total_credits_approved_not_equivalence
        ((creadits_approved  > 0) and aux&.is_a? Integer) ? (aux.to_f/creadits_approved.to_f).round(4) : 0.0     
    end
      
    def weighted_average_approved
        self.academic_records.weighted_average_approved
    end
      
    def total_credits_coursed
        academic_records.total_credits_coursed
    end
    
    def total_credits_approved
        academic_records.total_credits_approved
    end

    def total_credits_approved_not_equivalence
        academic_records.total_credits_approved_not_equivalence
    end

    def total_credits_coursed_not_equivalence
        academic_records.total_credits_coursed_not_equivalence
    end

end

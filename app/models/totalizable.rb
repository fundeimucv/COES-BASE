module Totalizable

  def total_academic_records
    academic_records.count
  end

  def total_sc
    academic_records.sin_calificar.count
  end

  def total_aprobados
    academic_records.not_perdida_por_inasistencia.aprobado.count
  end

  def total_aplazados
    academic_records.not_perdida_por_inasistencia.aplazado.count
  end

  def total_retirados
    academic_records.retirado.count
  end

  def total_pi
    academic_records.perdida_por_inasistencia.count
  end

  def label_numbery_total
    aux = ApplicationController.helpers.label_status_with_tooltip('bg-info me-1', total_academic_records, 'Inscritos')
    aux += ApplicationController.helpers.label_status_with_tooltip('bg-secondary me-1', total_sc, 'Sin Calificar')
    aux += ApplicationController.helpers.label_status_with_tooltip('bg-success me-1', total_aprobados, 'Aprobados')
    aux += ApplicationController.helpers.label_status_with_tooltip('bg-danger me-1', total_aplazados, 'Aplazados')
    aux += ApplicationController.helpers.label_status_with_tooltip('bg-secondary me-1', total_retirados, 'Retirdos')
    aux += ApplicationController.helpers.label_status_with_tooltip('bg-danger', total_pi, 'PI')  
  end
end

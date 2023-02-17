class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_admin, :current_teacher

  def models_list
    aux = ActiveRecord::Base.connection.tables-['schema_migrations', 'ar_internal_metadata'].map{|model| model.capitalize.singularize.camelize}
    return aux
  end

  def current_admin
    current_user.admin
  end

  def current_teacher
    current_user.teacher
  end

  def current_schools
    if current_admin
      env = current_admin.env_authorizable
      if env.is_a? Faculty
        env.schools
      elsif env.is_a? School
        School.where(id: env.id)
      end
    end    
  end

  def after_sign_in_path_for(resource)
    # dashboard_index_path
    rols = []
    rols << :admin if current_user.admin
    rols << :student if current_user.student
    rols << :teacher if current_user.teacher

    if rols.count > 1
      pages_multirols_path(id: rols)
    elsif current_user.admin?
      rails_admin_path
    elsif current_user.student?

      student_session_dashboard_path
    elsif current_user.teacher?
      # flash[:success] = current_teacher.user ? "¡Bienvenid#{current_teacher.user.genero} #{current_teacher.user.nick_name}!" : "¡Bienvenid@!"
      teacher_session_dashboard_path
    else
      flash[:warning] = "No posee un rol asignado. Por favor diríjase a la Administración para cambiar dicha situación"
      root_path 
    end
  end


  # def filtro_admin_alto_o_profe
  #   if !session[:administrador_id] or (current_admin and !current_admin.alto?) or !session[:profesor_id] 
  #     reset_session
  #     flash[:danger] = "Debe iniciar sesión como Profesor o Administrador superior"  
  #     redirect_to root_path
  #     return false
  #   end
  # end


  def authenticate_teacher!
    unless current_user.teacher?
      reset_session
      flash[:danger] = "Debe iniciar sesión como Profesor"  
      redirect_to root_path
    end
  end

  def authenticate_student!
    unless current_user.student?
      reset_session
      flash[:danger] = "Debe iniciar sesión como Profesor"  
      redirect_to root_path
    end
  end

  # def filtro_profesor
  #   unless session[:profesor_id]
  #     reset_session
  #     flash[:danger] = "Debe iniciar sesión como Profesor"  
  #     redirect_to root_path
  #     return false
  #   end
  # end

  # def filtro_estudiante
  #   unless session[:estudiante_id]
  #     reset_session
  #     flash[:danger] = "Debe iniciar sesión como Estudiante"  
  #     redirect_to root_path
  #     return false
  #   end
  # end



end

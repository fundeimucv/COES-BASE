class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_admin, :current_teacher, :current_teacher

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

  def set_session_id_if_multirols
    session[:rol] = params[:rol] if (current_user and session[:rol].nil?)
  end 


  def after_sign_in_path_for(resource)
    # dashboard_index_path
    rols = []
    rols << :admin if current_user.admin
    rols << :student if current_user.student
    rols << :teacher if current_user.teacher

    if rols.count > 1
      pages_multirols_path(roles: rols)
    elsif current_user.admin?
      rails_admin_path
    elsif current_user.student?
      student_session_dashboard_path
    elsif current_user.teacher?
      teacher_session_dashboard_path
    else
      flash[:warning] = "No posee un rol asignado. Por favor diríjase a la Administración para cambiar dicha situación"
      root_path 
    end
  end

end

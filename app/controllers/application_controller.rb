class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    # dashboard_index_path
    roles = []
    roles << :admin if current_user.admin
    roles << :student if current_user.student
    roles << :teacher if current_user.teacher

    if roles.count > 1
      home_path(id: roles)
    elsif current_user.admin?
      rails_admin_path
    elsif current_user.student?
      student_session_dashboard_path
    elsif current_user.teacher?
      teacher_session_dashboard_path
    else
      flash[:warning] = "No posee rol asignado. Por favor diríjase a un Administrador para cambiar dicha situación"
      root_path 
    end
  end

end

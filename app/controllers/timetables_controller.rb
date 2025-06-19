class TimetablesController < ApplicationController
  before_action :set_viewable, only: [:show]
  layout :select_layout

  def select_layout
    if current_user&.admin?
      'rails_admin/application'
    elsif current_user&.is_a?(Student)
      'logged'
    else
      'logged'
    end
  end
  def index
    @teachers = Teacher.includes(:user).order('users.last_name').limit(10)
    @sections = Section.includes(:subject, :course, :academic_process).order('subjects.code').limit(10)
  end
  
  def show
    @days = Timeblock.days.keys
    @start_hour = Timeblock::ALLOWED_START #7 # 7 AM
    @end_hour = Timeblock::ALLWOED_END #21  # 9 PM
    
    case @viewable_type
    when 'Teacher'
      @teacher = Teacher.find(params[:id])
      # @academic_process = @teacher.school.academic_processes.actives.or(@teacher.school.academic_processes.enrolls).first
      @academic_process = AcademicProcess.find(id: params[:academic_process_id]) if params[:academic_process_id].present?

      @timeblocks = Timeblock.joins(:timetable => {:section => {:course => :academic_process}})
                            .where("academic_processes.id": @academic_process.id)
                            .where(teacher_id: @teacher.id)
      @title = "Horario del Profesor: #{@teacher.user_description}"
    when 'Student'
      @student = Student.find(params[:id])
      # ids = @student.schools.joins(:academic_processes).where("active IS TRUE OR enroll IS TRUE").pluck(:'academic_processes.id')
      # @academic_process = AcademicProcess.where(id: ids).first
      @academic_process = AcademicProcess.find(params[:academic_process_id]) if params[:academic_process_id].present?

      @timeblocks = Timeblock.joins(:timetable => {:section => {:academic_records => {:enroll_academic_process => :academic_process}}})
                            .where(enroll_academic_processes: {grade_id: @student.grades.pluck(:id)})
                            .where("academic_processes.id": @academic_process.id)
                            .where.not('academic_records.status': 3) # Not retired
      @title = "Horario del Estudiante: #{@student.user.reverse_name}"
    when 'Section'
      @section = Section.find(params[:id])
      @academic_process = @section.academic_process
      @timeblocks = Timeblock.joins(:timetable).where(timetables: {section_id: @section.id})
      @title = "Horario de la Sección: #{@section.name}"
    else
    #   @timeblocks = Timeblock.all.limit(50)
    #   @title = "Todos los Horarios"
      flash[:alert] = "Sin tipo de vista especificado."
      redirect_back fallback_location: root_path
    end
    
    @time_slots = build_time_slots(@timeblocks)
  end
  
  private
  
  def set_viewable
    @viewable_type = params[:type] || 'All'
  end
  
  def build_time_slots(timeblocks)
    slots = {}
    
    timeblocks.each do |block|
      day = block.day
      start_time = block.start_time.strftime("%H:%M")
      end_time = block.end_time.strftime("%H:%M")
      
      slots[day] ||= {}
      slots[day][start_time] ||= []
      
      timetable = block.timetable
      section = timetable.section
      
      slots[day][start_time] << {
        id: block.id,
        academic_process: section.academic_process&.short_desc,
        title: section.subject_desc,
        subject_code: section.subject.code, 
        section_code: section.code,
        teacher: section.teacher&.user&.reverse_name || "Sin profesor",
        classroom: block.classroom || section.classroom || "Sin aula",
        start_time: start_time,
        end_time: end_time,
        modality: block.modality&.titleize,
        color: timetable.color || "rgba(200,200,200,0.3)",
        timetable_id: timetable.id
      }
    end
    
    slots
  end
end
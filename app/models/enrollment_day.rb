class EnrollmentDay < ApplicationRecord
  # SCHEMA:
  # t.bigint "academic_process_id", null: false
  # t.datetime "start"
  # t.integer "total_duration_hours", limit: 2
  # t.integer "max_grades", limit: 2
  # t.integer "slot_duration_minutes", limit: 2

  #RELATIONSHIPS:
  belongs_to :academic_process
  has_one :school, through: :academic_process 
  has_one :period, through: :academic_process 
  
  # VALIDACIONES
  validates :academic_process_id, presence: true
  validates :start, presence: true
  validates :total_duration_hours, presence: true
  validates :max_grades, presence: true
  validates :slot_duration_minutes, presence: true

  validates_with UniqEnrollmentDayValidator, field_name: false, if: :new_record?

  #CALLBACK
  after_destroy :clean_grades_with_appointment_time

  #SCOPE
  scope :actual, -> (academic_process_id) { where("academic_process_id = '#{academic_process_id}' and start LIKE '%#{Date.today}%'")}

  scope :del_dia, -> {where(start: Time.zone.now.all_day)}
  
  #MÉTODOS
  def can_enroll? appointment_time #puede_inscribir?
    Time.zone.now > appointment_time and Time.zone.now < appointment_time+self.slot_duration_minutes.minutes 
  end

  def total_timeslots #total_franjas
    (slot_duration_minutes.eql? 0) ? 0 : (self.total_duration_hours/self.slot_duration_minutes.to_f*60).to_i
  end

  def grades_by_timeslot #grado_x_franja 
    if total_timeslots > max_grades 
      return 1
    else
      (self.total_timeslots > 0) ? (max_grades/total_timeslots) : 0
    end
  end

  def own_grades_orders
    self.school.grades.with_day_enroll_eql_to(self.start).order([efficiency: :desc, simple_average: :desc, weighted_average: :desc])
  end

  def clean_grades_with_appointment_time
    self.own_grades_orders.update_all(appointment_time: nil, duration_slot_time: nil)
  end

end

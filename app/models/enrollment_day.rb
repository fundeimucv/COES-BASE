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
  scope :current_process, -> (academic_process_id) { of_today.where(academic_process_id: academic_process_id)}

  scope :of_today, -> {where(start: Time.zone.now.all_day)}
  
  def active_now?
    Time.zone.now > self.start and Time.zone.now < self.start+total_duration_hours.hours
  end

  #MÉTODOS

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


  def own_grades
    self.school.grades.with_day_enroll_eql_to(self.start)
  end

  def own_grades_count
    self.own_grades.count
  end

  def own_grades_sort_by_appointment
    self.own_grades.order([appointment_time: :asc, duration_slot_time: :asc])
  end

  def own_grades_sort_by_numbers
    self.own_grades.order([efficiency: :desc, simple_average: :desc, weighted_average: :desc])
  end

  def clean_grades_with_appointment_time
    self.own_grades.update_all(appointment_time: nil, duration_slot_time: nil)
  end

end

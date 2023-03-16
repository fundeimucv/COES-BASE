class Schedule < ApplicationRecord

  enum day: [:Lunes, :Martes, :Miércoles, :Jueves, :Viernes, :Sábado]  
  belongs_to :section

  validates :day, presence: true
  validates :starttime, presence: true
  validates :endtime, presence: true

  def name
    "#{day} #{starttime.strftime("de %I:%M%P") } #{endtime.strftime("a %I:%M%P") }"
  end

  rails_admin do
    show do
      field :name
    end
    edit do
      fields :day, :starttime, :endtime
    end
  end
end

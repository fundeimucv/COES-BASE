class Schedule < ApplicationRecord

  enum day: [:Lunes, :Martes, :Miércoles, :Jueves, :Viernes, :Sábado]  
  belongs_to :section

  validates :day, presence: true
  validates :starttime, presence: true
  validates :endtime, presence: true

  def short_name
    "#{day[0..1]} #{starttime.strftime("%I%P") } #{endtime.strftime("a %I%P") }"
    
  end

  def name
    "#{day} #{starttime.strftime("de %I:%M%P") } #{endtime.strftime("a %I:%M%P") }"
  end

  rails_admin do
    visible false
    show do
      field :name
    end
    edit do
      fields :day, :starttime, :endtime
    end
    export do
      field :name do
        label 'Horario'
      end

    end
  end
end
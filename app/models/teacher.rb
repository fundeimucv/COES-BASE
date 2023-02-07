class Teacher < ApplicationRecord
  # SCHEMA:
  # t.bigint "area_id", null: false

  # ASSOCIATIONS:
  belongs_to :user
  accepts_nested_attributes_for :user

  belongs_to :area
  # accepts_nested_attributes_for :area
  # has_and_belongs_to_many :secondary_teachers, class_name: 'SectionTeacher'

  has_many :sections

  # VALIDATIONS:
  validates :area, presence: true
  validates :user, presence: true, uniqueness: true

  def name
    self.user.name if self.user
  end

  # CALLBACKS:
  after_destroy :check_user_for_destroy
  
  # HOOKS:
  def check_user_for_destroy
    user_aux = User.find self.user_id
    user_aux.delete if user_aux.without_rol?
  end  

  def description
    if user
      aux = user.description
      aux += " - #{area.name}" if area
    else
      aux = 'Sin descripción'
    end
    return aux
  end

  rails_admin do
    navigation_label 'Gestión de Usuarios'
    navigation_icon 'fa-regular fa-chalkboard-user'

    list do
      exclude_fields :updated_at
    end

    show do
      fields :user, :area, :sections
    end

    edit do
      fields :user, :area
    end

    export do
      fields :user, :area, :created_at
    end

    import do
      fields :user_id, :area_id
    end
  end

  private

  def self.import row, fields

    total_newed = total_updated = 0
    no_registred = ""
    if area = Area.find(fields['area_id'])

      usuario = User.find_or_initialize_by(ci: row[0])
      usuario.email = row[1] if row[1]
      usuario.first_name = row[2] if row[2]
      usuario.last_name = row[3] if row[3]
      
      if row[4]
        row[4].strip!
        row[4].delete! '^A-Za-z'
        row[4] = :masculino if row[4].upcase.eql? 'M'
        row[4] = :femenino if row[4].upcase.eql? 'F'
        usuario.sex = row[4] 
      end
      usuario.number_phone = row[5] if row[5]
      
      nuevo = usuario.new_record?

      if usuario.save 
        profesor = Teacher.find_or_initialize_by(user_id: usuario.id)
        profesor.area_id = area.id

        nuevo = profesor.new_record?

        if profesor.save
          if nuevo
            total_newed = 1
          else
            total_updated = 1
          end
        else
          no_registred = row
        end
      else  
        no_registred = row
      end
    else
        no_registred = 'Área no encontrada'
    end
    [total_newed, total_updated, no_registred]    
  end


end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

p '      Creada Facultad!    '.center(200, '=') if fau = Faculty.create(code: 'FAU', name: 'Facultad de Arquitactura y urbanismo')

p '      Creado Primer Usuario!    '.center(200, '=') if user = User.create(email: 'moros.daniel@gmail.com', ci: '1', password: 123123)


p '      Creado Primer Admin!    '.center(200, '=') if Admin.create(user_id: user.id, role: :ninja, env_authorizable: fau)

p '      Creada Escuela!    '.center(200, '=') if escuela = School.create(code: 'EAU', name: 'Escuela de Arquitactura y urbanismo', faculty: fau)



p '      Creados Primeros Tipos de Períodos!    '.center(200, '=') if PeriodType.create([{code: 'I', name: 'Primero'}, {code: 'II', name: 'Segundo'}, {code: 'U', name: 'Único'}, {code: 'E', name: 'Especial (Intensivo)'}])


p '      Creados Primeros Períodos!    '.center(200, '=') if Period.create([{year: 2022, period_type_id: 1}, {year: 2022, period_type_id: 2}])

p '      Creado Primer Plan de Estudio!    '.center(200, '=') if StudyPlan.create(code: 'B001', name: 'Arquitecto')

p '      Creadas Primeras Asignturas Madres!    '.center(200, '=') if Area.create([{school_id: escuela.id, name: "Diseño Arquitectónico"},
{school_id: escuela.id, name: "Métodos"},
{school_id: escuela.id, name: "Tecnología"},
{school_id: escuela.id, name: "Historia y Crítica"},
{school_id: escuela.id, name: "Acondicionamiento Ambiental"},
{school_id: escuela.id, name: "Estudios Urbanos"}])

area = Area.where(name: "Diseño Arquitectónico").first

Area.create([{school_id: escuela.id, name: "Expresión", parent_area_id: area.id},
{school_id: escuela.id, name: "Teoría de la Arquitectura", parent_area_id: area.id},
{school_id: escuela.id, name: "Diseño Arquitectónico Sub", parent_area_id: area.id}])

area = Area.where(name: "Métodos").first

Area.create([{school_id: escuela.id, name: "Matemáticas", parent_area_id: area.id},
{school_id: escuela.id, name: "Investigación y Creatividad", parent_area_id: area.id},
{school_id: escuela.id, name: "Informática", parent_area_id: area.id}])

area = Area.where(name: "Tecnología").first

Area.create([{school_id: escuela.id, name: "Construcción", parent_area_id: area.id},
{school_id: escuela.id, name: "Instalaciones", parent_area_id: area.id},
{school_id: escuela.id, name: "Estructura", parent_area_id: area.id}])

p '      Creadas Subasignturas!    '.center(200, '=')
p '      FINAL    '.center(400, '*')



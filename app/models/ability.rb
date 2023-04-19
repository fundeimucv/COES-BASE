# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    alias_action :create, :read, :update, :export, to: :crue
    alias_action :read, :update, to: :ru
    alias_action :create, :read, to: :cr
    alias_action :create, :update, to: :cu
    alias_action :create, :update, :export, to: :cue

    user ||= User.new

    if user.admin?
      can :access, :rails_admin
      can :manage, :dashboard
      cannot :import, :all
      can :import, [User, Student, Teacher, Subject, Period, AcademicRecord, Billboard]

      if user.admin.yo?
        can :manage, :all
      elsif user.admin.jefe_control_estudio?
        can :manage, [Admin, Student, Teacher, Area, Subject, Bank, BankAccount, PaymentReport, Course, Grade, AcademicProcess, EnrollAcademicProcess, AcademicRecord, Section, AdmissionType, PeriodType, Address, StudyPlan, Period, Dependency, Schedule, EnrollmentDay, Billboard]
        can :crue, [School, User, Faculty]
      else

        # user.admin.authorizeds.each do |auth|

        #   if auth.cannot_all?
        #     cannot :manage, auth.clazz
        #   elsif auth.can_all?
        #     can :manage, auth.clazz
        #   else
        #     can :create, auth.clazz if auth.can_create?
        #     can :read, auth.clazz if auth.can_read?
        #     can :update, auth.clazz if auth.can_update?
        #     can :delete, auth.clazz if auth.can_delete?
        #     can :import, auth.clazz if auth.can_import?
        #     can :export, auth.clazz if auth.can_export?
        #   end
        # end
        cannot :manage, [User, Admin, Student, Teacher, Area, Subject, School, Bank, BankAccount, PaymentReport, Course, Grade, AcademicProcess, EnrollAcademicProcess, AcademicRecord, Section, AdmissionType, PeriodType, Address]
      end
    end
  end
end

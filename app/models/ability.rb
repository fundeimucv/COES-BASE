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
      can :read, Faculty

      if user.admin.yo?
        can :manage, :all
      elsif user.admin.jefe_control_estudio?
        can :import, Authorizable::IMPORTABLES
        can :manage, [Admin, Student, Teacher, Area, Subject, Bank, BankAccount, PaymentReport, Course, Grade, AcademicProcess, EnrollAcademicProcess, AcademicRecord, Section, AdmissionType, PeriodType, Address, StudyPlan, Period, Dependency, Schedule, EnrollmentDay, Billboard]
        can :crue, [School, User]
      else

        user.admin.authorizeds.each do |authd|

            can :read, authd.authorizable_klazz_constantenize if authd.can_read?
            can :create, authd.authorizable_klazz_constantenize if authd.can_create?
            can :update, authd.authorizable_klazz_constantenize if authd.can_update?
            can :delete, authd.authorizable_klazz_constantenize if authd.can_delete?
            can :import, authd.authorizable_klazz_constantenize if authd.can_import?
            can :export, authd.authorizable_klazz_constantenize if authd.can_export?
            # can :history_show, authd.authorizable_klazz_constantenize
            # can :history_index, authd.authorizable_klazz_constantenize

        end

        # cannot :manage, [User, Admin, Student, Teacher, Area, Subject, School, Bank, BankAccount, PaymentReport, Course, Grade, AcademicProcess, EnrollAcademicProcess, AcademicRecord, Section, AdmissionType, PeriodType, Address]
      end
    end
  end
end

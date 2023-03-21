class Bank < ApplicationRecord
  # SCHEMA:
    # t.string "code"
    # t.string "name" 


  # HISTORY:
  has_paper_trail on: [:create, :destroy, :update]

  # ASSOCIATION:
  has_many :payment_reports, foreign_key: :origin_bank_id

  # VALIDATIONS:
  validates :code, presence: true 
  validates :name, presence: true 


  # FUNCTIONS:
  def total_payment_reports
    payment_reports.count
  end

  # RAILS_ADMIN:
  rails_admin do
    navigation_label 'Finanzas'
    navigation_icon 'fa-solid fa-bank'

    list do
      fields :code, :name
      field :total_payment_reports do
        label 'Total Reporte Pagos'
      end
    end

    show do
      fields :code, :name
    end

    edit do
      fields :code, :name
    end

    export do
      fields :code, :name
    end

  end


end

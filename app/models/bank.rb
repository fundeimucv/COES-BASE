class Bank < ApplicationRecord
	# SCHEMA:
    # t.string "code"
    # t.string "name"	

	# ASSOCIATION:
	has_many :payment_reports, foreign_key: :origin_bank_id

	# VALIDATIONS:
	validates :code, presence: true 
	validates :name, presence: true 

  rails_admin do
    navigation_label 'Finanzas'
    navigation_icon 'fa-solid fa-bank'

    list do
    	fields :code, :name

    	field :total_payment_reports do
    		label 'Total Reporte Pagos'
    	end

    end
  end
  def total_payment_reports
  	payment_reports.count
  end
end

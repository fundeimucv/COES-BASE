class PaymentReportsController < ApplicationController
  before_action :set_payment_report, only: %i[ show edit update destroy ]

  # GET /payment_reports or /payment_reports.json
  def index
    @payment_reports = PaymentReport.all
  end

  # GET /payment_reports/1 or /payment_reports/1.json
  def show
  end

  # GET /payment_reports/new
  def new
    @payment_report = PaymentReport.new
  end

  # GET /payment_reports/1/edit
  def edit
  end

  # POST /payment_reports or /payment_reports.json
  def create
    @payment_report = PaymentReport.new(payment_report_params)

    respond_to do |format|
      if @payment_report.save
        format.html { redirect_to payment_report_url(@payment_report), notice: "Payment report was successfully created." }
        format.json { render :show, status: :created, location: @payment_report }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_reports/1 or /payment_reports/1.json
  def update
    respond_to do |format|
      if @payment_report.update(payment_report_params)
        format.html { redirect_to payment_report_url(@payment_report), notice: "Payment report was successfully updated." }
        format.json { render :show, status: :ok, location: @payment_report }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_reports/1 or /payment_reports/1.json
  def destroy
    @payment_report.destroy

    respond_to do |format|
      format.html { redirect_to payment_reports_url, notice: "Payment report was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_report
      @payment_report = PaymentReport.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_report_params
      params.require(:payment_report).permit(:amount, :transaction_id, :transaction_type, :transaction_date, :origin_bank_id, :payable_id)
    end
end

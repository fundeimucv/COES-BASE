class AcademicRecordsController < ApplicationController
  before_action :set_academic_record, only: %i[ show edit update destroy ]

  # GET /academic_records or /academic_records.json
  def index
    @academic_records = AcademicRecord.all
  end

  # GET /academic_records/1 or /academic_records/1.json
  def show
  end

  # GET /academic_records/new
  def new
    @academic_record = AcademicRecord.new
  end

  # GET /academic_records/1/edit
  def edit
  end

  # POST /academic_records or /academic_records.json
  def create
    @academic_record = AcademicRecord.new(academic_record_params)

    respond_to do |format|
      if @academic_record.save
        format.html { redirect_to academic_record_url(@academic_record), notice: "Academic record was successfully created." }
        format.json { render :show, status: :created, location: @academic_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @academic_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /academic_records/1 or /academic_records/1.json
  def update
    respond_to do |format|
      if @academic_record.update(academic_record_params)
        format.html { redirect_to academic_record_url(@academic_record), notice: "Academic record was successfully updated." }
        format.json { render :show, status: :ok, location: @academic_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @academic_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /academic_records/1 or /academic_records/1.json
  def destroy
    @academic_record.destroy

    respond_to do |format|
      format.html { redirect_to academic_records_url, notice: "Academic record was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_academic_record
      @academic_record = AcademicRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def academic_record_params
      params.require(:academic_record).permit(:section_id, :enroll_academic_process_id, :first_q, :second_q, :third_q, :final_q, :post_q, :status_q, :type_q)
    end
end

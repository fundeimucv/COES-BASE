class EnrollAcademicProcessesController < ApplicationController
  before_action :set_enroll_academic_process, only: %i[ show edit update destroy ]

  # GET /enroll_academic_processes or /enroll_academic_processes.json
  def index
    @enroll_academic_processes = EnrollAcademicProcess.all
  end

  # GET /enroll_academic_processes/1 or /enroll_academic_processes/1.json
  def show
  end

  # GET /enroll_academic_processes/new
  def new
    @enroll_academic_process = EnrollAcademicProcess.new
  end

  # GET /enroll_academic_processes/1/edit
  def edit
  end

  # POST /enroll_academic_processes or /enroll_academic_processes.json
  def create
    @enroll_academic_process = EnrollAcademicProcess.new(enroll_academic_process_params)

    respond_to do |format|
      if @enroll_academic_process.save
        format.html { redirect_to enroll_academic_process_url(@enroll_academic_process), notice: "Enroll academic process was successfully created." }
        format.json { render :show, status: :created, location: @enroll_academic_process }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @enroll_academic_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /enroll_academic_processes/1 or /enroll_academic_processes/1.json
  def update
    respond_to do |format|
      if @enroll_academic_process.update(enroll_academic_process_params)
        format.html { redirect_to enroll_academic_process_url(@enroll_academic_process), notice: "Enroll academic process was successfully updated." }
        format.json { render :show, status: :ok, location: @enroll_academic_process }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @enroll_academic_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enroll_academic_processes/1 or /enroll_academic_processes/1.json
  def destroy
    @enroll_academic_process.destroy

    respond_to do |format|
      format.html { redirect_to enroll_academic_processes_url, notice: "Enroll academic process was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_enroll_academic_process
      @enroll_academic_process = EnrollAcademicProcess.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def enroll_academic_process_params
      params.require(:enroll_academic_process).permit(:grade_id, :academic_process_id, :enroll_status, :permanence_status)
    end
end

class AcademicProcessesController < ApplicationController
  before_action :set_academic_process, only: %i[ show edit update destroy ]

  # GET /academic_processes or /academic_processes.json
  def index
    @academic_processes = AcademicProcess.all
  end

  # GET /academic_processes/1 or /academic_processes/1.json
  def show
  end

  # GET /academic_processes/new
  def new
    @academic_process = AcademicProcess.new
  end

  # GET /academic_processes/1/edit
  def edit
  end

  # POST /academic_processes or /academic_processes.json
  def create
    @academic_process = AcademicProcess.new(academic_process_params)

    respond_to do |format|
      if @academic_process.save
        format.html { redirect_to academic_process_url(@academic_process), notice: "Academic process was successfully created." }
        format.json { render :show, status: :created, location: @academic_process }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @academic_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /academic_processes/1 or /academic_processes/1.json
  def update
    respond_to do |format|
      if @academic_process.update(academic_process_params)
        format.html { redirect_to academic_process_url(@academic_process), notice: "Academic process was successfully updated." }
        format.json { render :show, status: :ok, location: @academic_process }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @academic_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /academic_processes/1 or /academic_processes/1.json
  def destroy
    @academic_process.destroy

    respond_to do |format|
      format.html { redirect_to academic_processes_url, notice: "Academic process was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_academic_process
      @academic_process = AcademicProcess.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def academic_process_params
      params.require(:academic_process).permit(:school_id, :period_id, :max_credit, :max_subjects)
    end
end

class EnrollAcademicProccesController < ApplicationController
  before_action :set_enroll_academic_procce, only: %i[ show edit update destroy ]

  # GET /enroll_academic_procces or /enroll_academic_procces.json
  def index
    @enroll_academic_procces = EnrollAcademicProcce.all
  end

  # GET /enroll_academic_procces/1 or /enroll_academic_procces/1.json
  def show
  end

  # GET /enroll_academic_procces/new
  def new
    @enroll_academic_procce = EnrollAcademicProcce.new
  end

  # GET /enroll_academic_procces/1/edit
  def edit
  end

  # POST /enroll_academic_procces or /enroll_academic_procces.json
  def create
    @enroll_academic_procce = EnrollAcademicProcce.new(enroll_academic_procce_params)

    respond_to do |format|
      if @enroll_academic_procce.save
        format.html { redirect_to enroll_academic_procce_url(@enroll_academic_procce), notice: "Enroll academic procce was successfully created." }
        format.json { render :show, status: :created, location: @enroll_academic_procce }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @enroll_academic_procce.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /enroll_academic_procces/1 or /enroll_academic_procces/1.json
  def update
    respond_to do |format|
      if @enroll_academic_procce.update(enroll_academic_procce_params)
        format.html { redirect_to enroll_academic_procce_url(@enroll_academic_procce), notice: "Enroll academic procce was successfully updated." }
        format.json { render :show, status: :ok, location: @enroll_academic_procce }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @enroll_academic_procce.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enroll_academic_procces/1 or /enroll_academic_procces/1.json
  def destroy
    @enroll_academic_procce.destroy

    respond_to do |format|
      format.html { redirect_to enroll_academic_procces_url, notice: "Enroll academic procce was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_enroll_academic_procce
      @enroll_academic_procce = EnrollAcademicProcce.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def enroll_academic_procce_params
      params.require(:enroll_academic_procce).permit(:grade_id, :academic_process_id, :enroll_status, :permanence_state)
    end
end

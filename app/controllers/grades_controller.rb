class GradesController < ApplicationController
  before_action :set_grade, only: %i[ show edit update destroy kardex ]

  # GET /grades or /grades.json
  def index
    @grades = Grade.all
  end

  # GET /grades/1 or /grades/1.json
  def show
    @school = @grade.school
    @faculty = @school.faculty
    @user = @grade.user
    @academic_records = @grade.academic_records
    @title = 'KARDEX'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'kardex', template: "grades/kardex", formats: [:html], page_size: 'letter', backgroud: false,  header:  {html: { content: '<h1>HOLA MUNDO</h1>'}}, footer: { center: 'Página: [page] de [topage]', font_size: '8'}
      end
    end
  end

  # GET /grades/new
  def new
    @grade = Grade.new
  end

  # GET /grades/1/edit
  def edit
  end

  # POST /grades or /grades.json
  def create
    @grade = Grade.new(grade_params)

    respond_to do |format|
      if @grade.save
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully created." }
        format.json { render :show, status: :created, location: @grade }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grades/1 or /grades/1.json
  def update
    respond_to do |format|
      if @grade.update(grade_params)
        format.html { redirect_to grade_url(@grade), notice: "Grade was successfully updated." }
        format.json { render :show, status: :ok, location: @grade }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grades/1 or /grades/1.json
  def destroy
    @grade.destroy

    respond_to do |format|
      format.html { redirect_to grades_url, notice: "Grade was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grade_params
      params.require(:grade).permit(:student_id, :study_plan_id, :graduate_status, :admission_type_id, :registration_status, :efficiency, :weighted_average, :simple_average)
    end

  private
    # GET Kardex
    def kardex
      @school = @enroll_academic_process.school
      @faculty = @school.faculty
      @user = @enroll_academic_process.user
      @period = @enroll_academic_process.period
      @academic_records = @enroll_academic_process.academic_records
      event = 'Se generó el Kardex'
      @kardex = params[:study] ? true : false
      file_name = "kardex#{@enroll_academic_process.short_name}"
      @title = 'KARDEX'
      respond_to do |format|
        format.html
        format.pdf do
          @version = @enroll_academic_process.versions.create(event: event)
          render pdf: file_name, template: "enroll_academic_processes/kardex", formats: [:html], page_size: 'letter', backgroud: false,  header:  {html: { content: '<h1>HOLA MUNDO</h1>'}}, footer: { center: '[page] de [topage]'}
        end
      end
      
    end

end

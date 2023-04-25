class GradesController < ApplicationController
  before_action :set_grade, only: %i[ show edit update destroy kardex ]

  # GET /grades or /grades.json
  def index
    @grades = Grade.all
  end

  def kardex
    school = @grade.school
    user = @grade.user
    respond_to do |format|
      format.pdf do
        # render pdf: "kardex-#{school.code}-#{user.ci}", locals: {grade: @grade}, formats: [:html], page_size: 'letter', footer: {center: "Página: [page] de [topage]", font_size: '10'}, header: {content: render_to_string(partial: 'personal_data_pdf'), formats: [:html], layout: false, font_size: '11', encoding: "UTF-8"}#, disposition: :attachment, margin: {top: 15}
        render pdf: "kardex-#{school.code}-#{user.ci}", locals: {grade: @grade}, formats: [:html], page_size: 'letter', header: {html: {template: '/grades/kardex_title', formats: [:html], layout: false}}, footer: {center: "Página: [page] de [topage]", font_size: '10'}, margin: {top: 40}#, disposition: :attachment

        # pdf_html = ActionController::Base.new.render_to_string(template: "grades/kardex", layout: 'pdf', locals: {grade: @grade})
        # pdf = WickedPdf.new.pdf_from_string(
        #   pdf_html,
        #   header: {content: render_to_string(partial: 'personal_data_pdf'), font_size: '8', show_as_html: true, formats: :html},
        #   footer: {center: "Página: [page] de [topage]", font_size: '10'}
        # )
        # send_data pdf, filename: "kardex-#{school.code}-#{user.ci}", disposition: :inline 

      end
    end      
  end

  # GET /grades/1 or /grades/1.json
  def show
    @school = @grade.school
    @faculty = @school.faculty
    @user = @grade.user
    @academic_records = @grade.academic_records
    @enroll_academic_processes = @grade.enroll_academic_processes
    respond_to do |format|
      format.html
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

end

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
    # @grade = Grade.find params[:grade_id]
    # @academic_process = AcademicProcess.find params[:academic_process_id]

    # @school = @grade.school
  end

  # GET /academic_records/1/edit
  def edit
  end

  # POST /academic_records or /academic_records.json
  def create
    1/0
    @academic_record = AcademicRecord.new(academic_record_params)

    if enroll_academic_process = @academic_record.enroll_academic_process
      if subject = Subject.find(params[:subject_id])
        if academic_process = @academic_record.academic_process
          course = Course.find_or_create_by(subject_id: params[:subject_id], academic_process_id: academic_process.id)

          section = Section.find_or_initialize_by(course.id, params[:section_code])

          if section.new_record?
            section.capacity = 30
            section.modality = params[:eq] ? :equivalencia : :nota_final
          end

          if section.save 
            @academic_record.section = section
            if @academic_record.save
              flash[:success] = 'Se guardó el historial'
              redirect_back fallback_location: root_path
            else
              flash[:darger] = "Error al intentar guardar el histórico: #{@academic_record.errors.full_messages.to_sentence}"
            end
          else
            flash[:danger] = 'Error al intentar guardar la sección. No se pudo completar el proceso:'+ section.errors.full_messages.to_sentence
          end

        else
          flash[:danger] = 'Periodo no encontrado'
        end
      else
        flash[:danger] = 'Asignatura no encontrada'
      end
    else
      flash[:danger] = 'Sin inscripción en sistema'
    end


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
        flash[:success] = '¡Actualización Exitosa!'
        format.html { redirect_back fallback_location: root_path}
        format.json { render json: {data: '¡Datos Guardados con éxito!', type: 'success'}, status: :ok }
      else
        flash[:danger] = @academic_record.errors.full_messages.to_sentence

        format.html { redirect_back fallback_location: root_path}
        format.json { render json: {data: "Error: #{@academic_record.errors.full_messages.to_sentence}", type: 'danger'}, status: :ok }
        # format.json { render json: @academic_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /academic_records/1 or /academic_records/1.json
  def destroy
    @academic_record.destroy
    flash[:info] = '¡Registro Eliminado!'

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path}
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
      params.require(:academic_record).permit(:section_id, :enroll_academic_process_id)
    end
end

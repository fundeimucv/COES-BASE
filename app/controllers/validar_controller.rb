class ValidarController < ApplicationController
  before_action :set_version, only: %i[ constancia_inscripcion ]
  skip_before_action :authenticate_user!, only: [ :constancia_inscripcion ]
  layout 'visitor'

  def constancia_inscripcion
    if @version and (@version.event.eql? 'Se generó Constancia de Inscripción') and @version.item.is_a? EnrollAcademicProcess
      flash[:success] = '¡Documento Válido!'
      @item = @version.item
    else
      flash[:danger] = 'Recurso no accesible. Puede que el documento no sea válido o halla sido alterado. Contacte a las autoridades para la validación del documento.'
      redirect_to root_path
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_version
      begin
        @enroll_academic_process = EnrollAcademicProcess.find (params[:object_id])
        crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
        
        params[:id] = "#{params[:id]}/#{params[:salt]}" unless (params[:salt].blank?)

        decrypted_id = crypt.decrypt_and_verify(params[:id])
        @version = @enroll_academic_process.versions.find(decrypted_id)
        
      rescue Exception => e
        flash[:danger] = 'Recurso no accesible. Puede que el documento no sea válido o halla sido alterado. Contacte a las autoridades para la validación del documento.'
        redirect_to root_path
      end
    end

end

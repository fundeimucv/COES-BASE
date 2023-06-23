class SchedulessController < ApplicationController
  before_action :set_section

  def create
    @section = Section.new(section_params)

    respond_to do |format|
      @section.schedules.create! schedules_attributes
      redirect_to @section
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:section_id])
    end

    def schedules_attributes
      params.require(:schedule).permit(:day, :starttime, :endtime)
    end
end

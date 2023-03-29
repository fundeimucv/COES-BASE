class BillboardsController < ApplicationController
  before_action :filtro_logueado
  before_action :filtro_administrador
  before_action :filtro_autorizado#, except: [:new, :edit]
  before_action :set_billboard, only: [:show, :edit, :update, :destroy, :set_active, :set_content]


  # GET /billboards
  # GET /billboards.json
  def set_active
    @billboard.active = !@billboard.active
    if @billboard.save
      aux = @billboard.active ? 'Cartelera Activada' : 'Cartelera Desactivada'
      render json: {data: aux, status: :success}
    else
      render json: {data: "Error al intentar cambiar la noticia : #{@comentario.errors.messages.to_sentence()}", status: :success}
    end

  end

  def index
    @title = "Cartelera"
    @billboards = Billboard.all
  end

  # GET /billboards/1
  # GET /billboards/1.json
  def show
    @title = "Vista previa de la Cartelera"
  end

  # GET /billboards/new
  def new
    @title = "Nueva Cartelera"
    @billboard = Billboard.new
  end

  # GET /billboards/1/edit
  def edit
    @title = "Editando Cartelera"
  end

  # POST /billboards
  # POST /billboards.json
  def create
    @billboard = Billboard.new(cartelera_params)

    respond_to do |format|
      if @billboard.save
        format.html { redirect_to billboards_path, notice: 'Cartelera creada con éxito.' }
        format.json { render :show, status: :created, location: @billboard }
      else
        format.html { render :new }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /billboards/1
  # PATCH/PUT /billboards/1.json
  def update
    respond_to do |format|
      if @billboard.update(billboard_params)
        format.html { redirect_to billboards_path, notice: 'Cartelera actualizada con éxito.' }
        format.json { render :show, status: :ok, location: @billboard }
      else
        format.html { render :edit }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /billboards/1
  # DELETE /billboards/1.json
  def destroy
    @billboard.destroy
    respond_to do |format|
      format.html { redirect_to billboards_url, notice: 'Cartelera eliminada con éxito.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_billboard
      @billboard = Billboard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def billboard_params
      params.require(:billboard).permit(:content, :active, :text)
    end
end
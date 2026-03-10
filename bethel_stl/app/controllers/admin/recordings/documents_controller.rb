class Admin::Recordings::DocumentsController < Admin::BaseController
  before_action :set_recording
  before_action :set_document, only: [:edit, :update, :destroy]

  def index
    @documents = @recording.documents.includes(file_attachment: :blob).order(created_at: :desc)
    render layout: false
  end

  def create
    @document = @recording.documents.build(document_params)

    respond_to do |format|
      if @document.save
        format.json { render json: { id: @document.id, filename: @document.file.filename.to_s }, status: :created }
      else
        format.json { render json: { errors: @document.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    render :edit_slideout, layout: false if params[:slideout]
  end

  def update
    if @document.update(document_params)
      if params[:slideout]
        render :update_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_recording_path(@recording)
      end
    elsif params[:slideout]
      render :edit_slideout, layout: false, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy

    respond_to do |format|
      format.turbo_stream { render :destroy_slideout, formats: [:turbo_stream], layout: false }
      format.html { redirect_to admin_recording_path(@recording), notice: 'Document deleted.' }
    end
  end

  private

  def set_recording
    @recording = Recording.find(params[:recording_id])
  end

  def set_document
    @document = @recording.documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :file)
  end
end

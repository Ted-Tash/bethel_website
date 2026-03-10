class Admin::RecordingsController < Admin::BaseController
  before_action :set_recording, only: [:show, :edit, :update, :destroy, :editor, :save_edit, :restore_original, :update_duration]

  def index
    @recordings = Recording.order(recorded_on: :desc, created_at: :desc)
  end

  def show
    if params[:slideout]
      render :show_slideout, layout: false
    end
  end

  def new
    @recording = Recording.new

    if params[:slideout]
      render :new_slideout, layout: false
    end
  end

  def create
    @recording = Recording.new(recording_params)

    if @recording.save
      if params[:slideout]
        render :create_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_recordings_path, notice: 'Sermon was successfully created.'
      end
    elsif params[:slideout]
      render :new_slideout, layout: false, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if params[:slideout]
      render :edit_slideout, layout: false
    end
  end

  def update
    if @recording.update(recording_params)
      if params[:slideout]
        render :update_slideout, formats: [:turbo_stream], layout: false
      else
        redirect_to admin_recordings_path, notice: 'Sermon was successfully updated.'
      end
    elsif params[:slideout]
      render :edit_slideout, layout: false, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recording.destroy

    respond_to do |format|
      format.turbo_stream { render :destroy_slideout, formats: [:turbo_stream], layout: false }
      format.html { redirect_to admin_recordings_path, notice: 'Sermon was successfully deleted.' }
    end
  end

  def editor
    unless @recording.audio.attached?
      redirect_to admin_recordings_path, alert: 'Upload an audio file before editing.'
      return
    end
  end

  def save_edit
    unless params[:audio].present?
      redirect_to editor_admin_recording_path(@recording), alert: 'No audio data received.'
      return
    end

    # Preserve the original audio before first edit
    unless @recording.original_audio.attached?
      @recording.original_audio.attach(
        io: StringIO.new(@recording.audio.download),
        filename: "original_#{@recording.audio.filename}",
        content_type: @recording.audio.content_type
      )
    end

    @recording.audio.attach(params[:audio])

    respond_to do |format|
      format.json { render json: { redirect_to: editor_admin_recording_path(@recording) }, status: :ok }
      format.html { redirect_to editor_admin_recording_path(@recording), notice: 'Edit saved successfully.' }
    end
  end

  def update_duration
    @recording.update(duration_seconds: params[:duration_seconds].to_i)
    head :ok
  end

  def restore_original
    unless @recording.original_audio.attached?
      redirect_to editor_admin_recording_path(@recording), alert: 'No original audio to restore.'
      return
    end

    @recording.audio.attach(
      io: StringIO.new(@recording.original_audio.download),
      filename: @recording.original_audio.filename.to_s.sub(/\Aoriginal_/, ''),
      content_type: @recording.original_audio.content_type
    )
    @recording.original_audio.purge
    redirect_to editor_admin_recording_path(@recording), notice: 'Original audio restored.'
  end

  private

  def set_recording
    @recording = Recording.find(params[:id])
  end

  def recording_params
    permitted = [:title, :speaker_name, :recorded_on, :duration_seconds]
    permitted << :audio if action_name == 'create'
    params.require(:recording).permit(permitted)
  end
end

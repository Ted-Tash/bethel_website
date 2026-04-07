class Admin::AudioExtractionsController < Admin::BaseController
  def index
    @audio_extractions = AudioExtraction.recent.limit(50)
  end

  def show
    @audio_extraction = AudioExtraction.find(params[:id])
  end

  def new
    @audio_extraction = AudioExtraction.new
  end

  def create
    @audio_extraction = AudioExtraction.new(audio_extraction_params)

    if @audio_extraction.save
      ExtractAudioJob.perform_later(@audio_extraction.id)
      redirect_to admin_audio_extraction_path(@audio_extraction)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @audio_extraction = AudioExtraction.find(params[:id])
    @audio_extraction.destroy
    redirect_to admin_audio_extractions_path, notice: 'Extraction deleted.'
  end

  private

  def audio_extraction_params
    params.require(:audio_extraction).permit(:youtube_url, :start_time, :end_time)
  end
end

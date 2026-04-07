class Admin::EventsController < Admin::BaseController
  before_action :set_calendar_source, only: [:sync, :destroy_source]

  def index
    @calendar_sources = CalendarSource.all
    @events = Event.includes(:calendar_source).upcoming.order(starts_at: :asc)
  end

  # POST /admin/events/add_source
  def add_source
    @source = CalendarSource.new(calendar_source_params)
    if @source.save
      redirect_to admin_events_path, notice: "Calendar source '#{@source.name}' added."
    else
      redirect_to admin_events_path, alert: @source.errors.full_messages.to_sentence
    end
  end

  # POST /admin/events/:calendar_source_id/sync
  def sync
    result = GoogleCalendarService.sync(@source)
    redirect_to admin_events_path,
      notice: "Synced '#{@source.name}': #{result[:imported]} imported, #{result[:updated]} updated."
  rescue => e
    redirect_to admin_events_path, alert: "Sync failed: #{e.message}"
  end

  # DELETE /admin/events/sources/:id
  def destroy_source
    name = @source.name
    @source.destroy
    redirect_to admin_events_path, notice: "Removed calendar source '#{name}' and all its events."
  end

  # PATCH /admin/events/:id/toggle_public
  def toggle_public
    @event = Event.find(params[:id])
    @event.update!(public: !@event.public?)
    redirect_to admin_events_path, notice: "'#{@event.title}' is now #{@event.public? ? 'public' : 'hidden'}."
  end

  private

  def set_calendar_source
    @source = CalendarSource.find(params[:calendar_source_id] || params[:id])
  end

  def calendar_source_params
    params.require(:calendar_source).permit(:name, :google_calendar_id)
  end
end

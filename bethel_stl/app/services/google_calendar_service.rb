class GoogleCalendarService
  Event = Data.define(:title, :description, :start_time, :end_time, :location)

  CACHE_KEY = "google_calendar/upcoming_events"
  CACHE_DURATION = 15.minutes

  class << self
    def upcoming_events(limit: 3)
      return [] unless configured?

      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
        fetch_events(limit)
      end
    rescue => e
      Rails.logger.error("GoogleCalendarService: #{e.message}")
      []
    end

    private

    def configured?
      api_key.present? && calendar_id.present?
    end

    def api_key
      Rails.application.credentials.dig(:google_calendar, :api_key)
    end

    def calendar_id
      Rails.application.credentials.dig(:google_calendar, :calendar_id)
    end

    def fetch_events(limit)
      service = Google::Apis::CalendarV3::CalendarService.new
      service.key = api_key

      results = service.list_events(
        calendar_id,
        max_results: limit,
        single_events: true,
        order_by: "startTime",
        time_min: Time.current.iso8601
      )

      (results.items || []).map { |item| build_event(item) }
    end

    def build_event(item)
      Event.new(
        title: item.summary || "Untitled Event",
        description: item.description,
        start_time: parse_event_time(item.start),
        end_time: parse_event_time(item.end),
        location: item.location
      )
    end

    def parse_event_time(event_time)
      return nil unless event_time
      event_time.date_time || Date.parse(event_time.date)
    end
  end
end

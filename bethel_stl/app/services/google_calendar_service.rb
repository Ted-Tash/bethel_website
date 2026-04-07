class GoogleCalendarService
  class << self
    # Sync events from a CalendarSource into the events table.
    # New events default to public: false so admin can choose which to show.
    def sync(calendar_source, months_ahead: 6)
      raise "Google Calendar API key not configured" unless api_key.present?

      service = Google::Apis::CalendarV3::CalendarService.new
      service.key = api_key

      results = service.list_events(
        calendar_source.google_calendar_id,
        single_events: true,
        order_by: "startTime",
        time_min: Time.current.iso8601,
        time_max: months_ahead.months.from_now.iso8601,
        max_results: 250
      )

      imported = 0
      updated = 0

      (results.items || []).each do |item|
        event = calendar_source.events.find_or_initialize_by(google_event_id: item.id)
        is_new = event.new_record?

        event.assign_attributes(
          title: item.summary || "Untitled Event",
          description: item.description,
          location: item.location,
          starts_at: parse_time(item.start),
          ends_at: parse_time(item.end),
          all_day: item.start&.date.present?
        )

        if event.changed?
          event.save!
          is_new ? imported += 1 : updated += 1
        end
      end

      { imported: imported, updated: updated }
    end

    private

    def api_key
      Rails.application.credentials.dig(:google_calendar, :api_key)
    end

    def parse_time(event_time)
      return nil unless event_time
      if event_time.date_time
        event_time.date_time
      elsif event_time.date
        Date.parse(event_time.date).beginning_of_day
      end
    end
  end
end

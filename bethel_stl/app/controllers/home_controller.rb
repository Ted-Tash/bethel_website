class HomeController < ApplicationController
  def index
    @events = GoogleCalendarService.upcoming_events
  end
end

class HomeController < ApplicationController
  def index
    @events = Event.upcoming_public.limit(6)
  end
end

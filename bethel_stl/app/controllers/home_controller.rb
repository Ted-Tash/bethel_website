class HomeController < ApplicationController
  def index
    @events = Event.upcoming_public.limit(6)
    livestream = Rails.cache.read("youtube_livestream")
    @youtube_url = if livestream&.dig(:live)
      livestream[:video_url]
    else
      "https://www.youtube.com/channel/UCFrJtSIyNcu3Lv2p-1q7AFQ/live"
    end
  end
end

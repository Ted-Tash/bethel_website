class HomeController < ApplicationController
  def index
    @events = Event.upcoming_public.limit(6)
    @show_pinecrest_registration_modal = Date.current.between?(Date.new(2026, 8, 16), Date.new(2026, 9, 14))
    livestream = Rails.cache.read("youtube_livestream")
    @youtube_url = if livestream&.dig(:live)
      livestream[:video_url]
    else
      "https://www.youtube.com/channel/UCFrJtSIyNcu3Lv2p-1q7AFQ/live"
    end
  end
end

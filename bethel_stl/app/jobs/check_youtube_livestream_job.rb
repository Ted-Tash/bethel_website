class CheckYoutubeLivestreamJob < ApplicationJob
  CHANNEL_ID = "UCFrJtSIyNcu3Lv2p-1q7AFQ"
  CHANNEL_LIVE_URL = "https://www.youtube.com/channel/#{CHANNEL_ID}/live"
  CACHE_KEY = "youtube_livestream"
  CACHE_TTL = 10.minutes

  def perform
    result = fetch_livestream_status
    Rails.cache.write(CACHE_KEY, result, expires_in: CACHE_TTL)
    Rails.logger.info("[YouTubeLivestream] #{result[:live] ? "LIVE: #{result[:video_url]}" : "Not live"}")
  end

  private

  def fetch_livestream_status
    uri = URI(CHANNEL_LIVE_URL)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "Mozilla/5.0 (compatible; BethelChurchBot/1.0)"
      http.request(request)
    end

    return not_live unless response.is_a?(Net::HTTPSuccess)

    body = response.body
    if body.include?('"isLive":true')
      video_id = extract_video_id(body)
      if video_id
        { live: true, video_url: "https://www.youtube.com/watch?v=#{video_id}" }
      else
        not_live
      end
    else
      not_live
    end
  rescue StandardError => e
    Rails.logger.warn("[YouTubeLivestream] Error checking livestream: #{e.class} - #{e.message}")
    not_live
  end

  def extract_video_id(body)
    # Try canonical URL first: <link rel="canonical" href="https://www.youtube.com/watch?v=VIDEO_ID">
    if (match = body.match(%r{<link\s+rel="canonical"\s+href="https://www\.youtube\.com/watch\?v=([^"&]+)"}))
      return match[1]
    end

    # Fall back to videoId in JSON data
    if (match = body.match(/"videoId":"([a-zA-Z0-9_-]{11})"/))
      return match[1]
    end

    nil
  end

  def not_live
    { live: false }
  end
end

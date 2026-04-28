require "rss"

class SermonsController < ApplicationController
  FEED_URL = "https://sermons.bethelstl.com/feed.rss"
  CACHE_KEY = "sermons_rss_feed"
  CACHE_TTL = 1.hour

  def index
    sermons = fetch_sermons
    @featured_sermon = sermons.shift
    @sermons = sermons
  rescue StandardError => e
    Rails.logger.warn("[Sermons] Error loading RSS feed: #{e.class} - #{e.message}")
    @feed_error = true
    @featured_sermon = nil
    @sermons = []
  end

  private

  def fetch_sermons
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) do
      parse_feed(fetch_feed)
    end
  end

  def fetch_feed
    uri = URI(FEED_URL)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "Mozilla/5.0 (compatible; BethelChurchBot/1.0)"
      http.request(request)
    end

    raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    response.body
  end

  def parse_feed(xml)
    feed = RSS::Parser.parse(xml, false)
    feed.items.map do |item|
      {
        title: item.title,
        link: item.link,
        speaker: extract_speaker(item),
        date: item.pubDate&.to_date || Date.current,
        duration: item.respond_to?(:itunes_duration) ? item.itunes_duration&.content : nil,
        audio_url: item.enclosure&.url,
        summary: extract_summary(item),
        series: extract_series(item)
      }
    end
  end

  def extract_speaker(item)
    if item.respond_to?(:itunes_author) && item.itunes_author.present?
      item.itunes_author
    elsif item.respond_to?(:dc_creator) && item.dc_creator.present?
      item.dc_creator
    else
      "Bethel Community Church"
    end
  end

  def extract_summary(item)
    desc = item.description.to_s
    # Strip HTML tags and clean up
    text = desc.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
    # Return nil if it's just the title repeated
    text.present? && text != item.title ? text : nil
  end

  def extract_series(item)
    desc = item.description.to_s
    if (match = desc.match(/<strong>Series:\s*<\/strong>([^<]+)/))
      match[1].strip.presence
    end
  end
end

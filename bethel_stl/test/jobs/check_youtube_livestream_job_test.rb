require "test_helper"
require "net/http"

class CheckYoutubeLivestreamJobTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "stores live status with video URL when stream is live" do
    body = <<~HTML
      <html>
      <link rel="canonical" href="https://www.youtube.com/watch?v=dQw4w9WgXcQ">
      <script>{"isLive":true,"videoId":"dQw4w9WgXcQ"}</script>
      </html>
    HTML

    perform_with_stubbed_response(body: body)

    result = Rails.cache.read("youtube_livestream")
    assert result[:live]
    assert_equal "https://www.youtube.com/watch?v=dQw4w9WgXcQ", result[:video_url]
  end

  test "stores not-live status when stream is offline" do
    body = <<~HTML
      <html>
      <link rel="canonical" href="https://www.youtube.com/channel/UCFrJtSIyNcu3Lv2p-1q7AFQ">
      <script>{"isLive":false}</script>
      </html>
    HTML

    perform_with_stubbed_response(body: body)

    result = Rails.cache.read("youtube_livestream")
    assert_not result[:live]
    assert_nil result[:video_url]
  end

  test "stores not-live on network error" do
    original_start = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*_args, **_kwargs, &_block| raise Timeout::Error, "timed out" }

    CheckYoutubeLivestreamJob.perform_now

    result = Rails.cache.read("youtube_livestream")
    assert_not result[:live]
  ensure
    Net::HTTP.define_singleton_method(:start, original_start)
  end

  test "stores not-live when isLive true but no video ID found" do
    body = '<html><script>{"isLive":true}</script></html>'

    perform_with_stubbed_response(body: body)

    result = Rails.cache.read("youtube_livestream")
    assert_not result[:live]
  end

  test "extracts video ID from videoId JSON field as fallback" do
    body = <<~HTML
      <html>
      <script>{"isLive":true,"videoId":"abc123DEF_-"}</script>
      </html>
    HTML

    perform_with_stubbed_response(body: body)

    result = Rails.cache.read("youtube_livestream")
    assert result[:live]
    assert_equal "https://www.youtube.com/watch?v=abc123DEF_-", result[:video_url]
  end

  test "defaults to not-live when cache is empty" do
    result = Rails.cache.read("youtube_livestream")
    assert_nil result
  end

  private

  def perform_with_stubbed_response(body:)
    response = Net::HTTPSuccess.new("1.1", "200", "OK")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, body)

    original_start = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*_args, **_kwargs, &_block| response }

    CheckYoutubeLivestreamJob.perform_now
  ensure
    Net::HTTP.define_singleton_method(:start, original_start)
  end
end

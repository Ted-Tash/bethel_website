class ExtractAudioJob < ApplicationJob
  queue_as :default

  def perform(audio_extraction_id)
    extraction = AudioExtraction.find(audio_extraction_id)
    extraction.update!(status: 'processing')

    tmp_dir = Rails.root.join('tmp', 'audio_extractions')
    FileUtils.mkdir_p(tmp_dir)

    output_path = tmp_dir.join("extraction_#{extraction.id}.mp3").to_s

    # Step 1: Get the direct audio stream URL from YouTube
    audio_url = fetch_audio_url(extraction)

    # Step 2: Use ffmpeg to download just the segment and convert to MP3
    ffmpeg_command = build_ffmpeg_command(extraction, audio_url, output_path)

    Rails.logger.info "[AudioExtraction ##{extraction.id}] Running ffmpeg for segment"

    stdout, stderr, status = Open3.capture3(*ffmpeg_command)

    unless status.success?
      extraction.update!(status: 'failed', error_message: stderr.last(1000).presence || stdout.last(1000))
      broadcast_result(extraction)
      return
    end

    unless File.exist?(output_path) && File.size(output_path) > 0
      extraction.update!(status: 'failed', error_message: 'Output file not found or empty after extraction')
      broadcast_result(extraction)
      return
    end

    extraction.audio_file.attach(
      io: File.open(output_path),
      filename: "#{extraction.id}-audio.mp3",
      content_type: 'audio/mpeg'
    )

    extraction.update!(
      status: 'completed',
      filename: "#{extraction.id}-audio.mp3",
      file_size: File.size(output_path)
    )

    broadcast_result(extraction)
  rescue => e
    extraction&.update(status: 'failed', error_message: e.message)
    broadcast_result(extraction) if extraction
    raise
  ensure
    File.delete(output_path) if output_path && File.exist?(output_path)
  end

  private

  def broadcast_result(extraction)
    Turbo::StreamsChannel.broadcast_replace_to(
      "audio_extraction_#{extraction.id}",
      target: 'audio_extraction_container',
      partial: 'admin/audio_extractions/result',
      locals: { audio_extraction: extraction }
    )

  end

  def fetch_audio_url(extraction)
    cmd = ['yt-dlp', '-f', 'bestaudio', '--get-url', '--no-playlist', extraction.youtube_url]
    stdout, stderr, status = Open3.capture3(*cmd)

    unless status.success?
      raise "Failed to get audio URL: #{stderr.last(500)}"
    end

    stdout.strip
  end

  def build_ffmpeg_command(extraction, audio_url, output_path)
    cmd = ['ffmpeg', '-y', '-hide_banner']

    if extraction.start_time.present?
      cmd += ['-ss', extraction.start_time]
    end

    if extraction.end_time.present?
      cmd += ['-to', extraction.end_time]
    end

    cmd += ['-i', audio_url, '-vn', '-acodec', 'libmp3lame', '-q:a', '2', output_path]
    cmd
  end
end

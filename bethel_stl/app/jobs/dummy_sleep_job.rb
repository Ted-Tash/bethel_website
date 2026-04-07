class DummySleepJob < ApplicationJob
  queue_as :default

  def perform
    sleep 10
    Turbo::StreamsChannel.broadcast_replace_to(
      'dummy_job',
      target: 'dummy_job_container',
      partial: 'admin/dummy/done'
    )
  end
end

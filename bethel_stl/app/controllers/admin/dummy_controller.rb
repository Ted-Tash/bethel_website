class Admin::DummyController < Admin::BaseController
  def index
  end

  def enqueue
    DummySleepJob.perform_later
    render turbo_stream: turbo_stream.replace('dummy_job_container', partial: 'admin/dummy/running')
  end
end

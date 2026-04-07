class Admin::MessagesController < Admin::BaseController
  def index
    @messages = Message.recent.includes(:contact_group)
  end

  def new
    @message = Message.new
    @contact_groups = ContactGroup.order(:name)
  end

  def create
    @message = Message.new(message_params)
    @message.status = :scheduled

    if params[:commit] == "Send Now"
      @message.scheduled_at = nil
    end

    if @message.save
      if @message.send_now?
        SendMessageJob.perform_later(@message.id)
      else
        SendMessageJob.set(wait_until: @message.scheduled_at).perform_later(@message.id)
      end

      redirect_to admin_message_path(@message), notice: @message.send_now? ? "Message is being sent." : "Message has been scheduled."
    else
      @contact_groups = ContactGroup.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @message = Message.find(params[:id])
    @deliveries = @message.message_deliveries.includes(:member).order(:created_at)
  end

  private

  def message_params
    params.require(:message).permit(:body, :contact_group_id, :scheduled_at, :channel)
  end
end

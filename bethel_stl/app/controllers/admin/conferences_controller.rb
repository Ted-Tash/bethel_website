class Admin::ConferencesController < Admin::BaseController
  before_action :set_conference, only: [ :show, :edit, :update, :destroy ]

  def index
    @conferences = Conference.chronological.includes(:questions, :registrations)
  end

  def show
    render :show_slideout, layout: false if params[:slideout]
  end

  def new
    @conference = Conference.new

    if params[:slideout]
      render :new_slideout, layout: false
    else
      redirect_to admin_conferences_path
    end
  end

  def create
    @conference = Conference.new(conference_params)

    if @conference.save
      if params[:slideout]
        render :create_slideout, formats: [ :turbo_stream ], layout: false
      else
        redirect_to admin_conference_path(@conference), notice: "Conference was successfully created."
      end
    elsif params[:slideout]
      render :new_slideout, layout: false, status: :unprocessable_entity
    else
      redirect_to admin_conferences_path, alert: @conference.errors.full_messages.to_sentence
    end
  end

  def edit
    if params[:slideout]
      render :edit_slideout, layout: false
    else
      redirect_to admin_conferences_path
    end
  end

  def update
    if @conference.update(conference_params)
      if params[:slideout]
        template = params[:context] == "show" ? :update_show_slideout : :update_slideout
        render template, formats: [ :turbo_stream ], layout: false
      else
        redirect_to admin_conference_path(@conference), notice: "Conference was successfully updated."
      end
    elsif params[:slideout]
      render :edit_slideout, layout: false, status: :unprocessable_entity
    else
      redirect_to admin_conferences_path, alert: @conference.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @conference.destroy
      respond_to do |format|
        format.turbo_stream { render :destroy_slideout, formats: [ :turbo_stream ], layout: false }
        format.html { redirect_to admin_conferences_path, notice: "Conference was successfully deleted." }
      end
    else
      redirect_to admin_conference_path(@conference), alert: @conference.errors.full_messages.to_sentence
    end
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:id])
  end

  def conference_params
    params.require(:conference).permit(:name, :slug, :description, :location, :starts_at, :ends_at, :registration_open)
  end
end

class Admin::ConferenceRegistrationsController < Admin::BaseController
  before_action :set_conference
  before_action :set_registration, only: [ :show, :edit, :update, :cancel, :reactivate ]

  def index
    load_report

    respond_to do |format|
      format.html
      format.csv do
        send_data ConferenceRegistrationsCsv.new(@conference, registrations: @registrations).generate,
          filename: "#{@conference.slug}-registrations-#{Date.current.iso8601}.csv",
          type: "text/csv; charset=utf-8"
      end
    end
  end

  def show
    if params[:slideout]
      render :show_slideout, layout: false
    else
      redirect_to admin_conference_registrations_path(@conference)
    end
  end

  def edit
    build_missing_answers

    if params[:slideout]
      render :edit_slideout, layout: false
    else
      redirect_to admin_conference_registrations_path(@conference)
    end
  end

  def update
    if @registration.update(registration_params)
      if params[:slideout]
        render :update_slideout, formats: [ :turbo_stream ], layout: false
      else
        redirect_to admin_conference_registrations_path(@conference), notice: "Registration was successfully updated."
      end
    else
      build_missing_answers
      if params[:slideout]
        render :edit_slideout, layout: false, status: :unprocessable_entity
      else
        redirect_to admin_conference_registrations_path(@conference), alert: @registration.errors.full_messages.to_sentence
      end
    end
  end

  def cancel
    @registration.cancel!
    respond_to_status_change("Registration was cancelled.")
  end

  def reactivate
    @registration.reactivate!
    respond_to_status_change("Registration was reactivated.")
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_id])
  end

  def set_registration
    @registration = @conference.registrations.includes(answers: :question).find(params[:id])
  end

  def build_missing_answers
    answered_question_ids = @registration.answers.map(&:conference_question_id)
    @conference.questions.each do |question|
      @registration.answers.build(question: question) unless question.id.in?(answered_question_ids)
    end
  end

  def load_report
    @report = ConferenceRegistrationsReport.new(
      @conference,
      search: params.permit(:search)[:search],
      status: params.permit(:status)[:status]
    )
    @questions = @report.questions
    @filterable_questions = @report.filterable_questions
    @registrations = @report.registrations
    @response_counts = @report.response_counts
  end

  def respond_to_status_change(message)
    respond_to do |format|
      format.turbo_stream do
        flash[:notice] = message
        render :status_changed, formats: [ :turbo_stream ], layout: false
      end
      format.html { redirect_to admin_conference_registrations_path(@conference), notice: message }
    end
  end

  def registration_params
    params.require(:conference_registration).permit(
      :first_name, :last_name, :email, :phone,
      answers_attributes: [ :id, :conference_question_id, :value, { value: [] } ]
    )
  end
end

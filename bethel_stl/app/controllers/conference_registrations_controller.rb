class ConferenceRegistrationsController < ApplicationController
  before_action :set_conference
  before_action :require_open_registration, only: [ :new, :create ]

  def new
    @registration = @conference.registrations.build
    build_answers
  end

  def create
    @registration = @conference.registrations.build(registration_params)

    if @registration.save
      redirect_to conference_registration_thanks_path(@conference)
    else
      build_answers
      render :new, status: :unprocessable_entity
    end
  end

  def thanks
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
  end

  def require_open_registration
    return if @conference.registration_open?

    render :closed, status: :not_found
  end

  def build_answers
    answered_question_ids = @registration.answers.map(&:conference_question_id)
    @conference.questions.each do |question|
      @registration.answers.build(question: question) unless question.id.in?(answered_question_ids)
    end
  end

  def registration_params
    params.require(:conference_registration).permit(
      :first_name, :last_name, :email, :phone,
      answers_attributes: [ :conference_question_id, :value, { value: [] } ]
    )
  end
end

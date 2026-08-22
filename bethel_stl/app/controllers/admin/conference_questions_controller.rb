class Admin::ConferenceQuestionsController < Admin::BaseController
  before_action :set_conference
  before_action :set_question, only: [ :edit, :update, :destroy ]

  def new
    @question = @conference.questions.build(position: next_position)

    if params[:slideout]
      render :new_slideout, layout: false
    else
      redirect_to admin_conference_path(@conference)
    end
  end

  def create
    @question = @conference.questions.build(question_params)
    @question.position = next_position

    if @question.save
      if params[:slideout]
        render :create_slideout, formats: [ :turbo_stream ], layout: false
      else
        redirect_to admin_conference_path(@conference), notice: "Registration question was successfully created."
      end
    elsif params[:slideout]
      render :new_slideout, layout: false, status: :unprocessable_entity
    else
      redirect_to admin_conference_path(@conference), alert: @question.errors.full_messages.to_sentence
    end
  end

  def edit
    if params[:slideout]
      render :edit_slideout, layout: false
    else
      redirect_to admin_conference_path(@conference)
    end
  end

  def update
    if @question.update(question_params)
      if params[:slideout]
        render :update_slideout, formats: [ :turbo_stream ], layout: false
      else
        redirect_to admin_conference_path(@conference), notice: "Registration question was successfully updated."
      end
    elsif params[:slideout]
      render :edit_slideout, layout: false, status: :unprocessable_entity
    else
      redirect_to admin_conference_path(@conference), alert: @question.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @question.destroy
      normalize_positions
      respond_to do |format|
        format.turbo_stream { render :destroy_slideout, formats: [ :turbo_stream ], layout: false }
        format.html { redirect_to admin_conference_path(@conference), notice: "Registration question was successfully deleted." }
      end
    else
      redirect_to admin_conference_path(@conference), alert: @question.errors.full_messages.to_sentence
    end
  end

  def reorder
    question_ids = Array(params[:question_ids]).map(&:to_i)
    existing_ids = @conference.questions.pluck(:id)

    unless question_ids.length == existing_ids.length && question_ids.sort == existing_ids.sort
      return head :unprocessable_entity
    end

    ConferenceQuestion.transaction do
      question_ids.each_with_index do |question_id, index|
        @conference.questions.where(id: question_id).update_all(position: index + 1)
      end
    end

    head :no_content
  end

  private

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_id])
  end

  def set_question
    @question = @conference.questions.find(params[:id])
  end

  def next_position
    @conference.questions.maximum(:position).to_i + 1
  end

  def normalize_positions
    @conference.questions.reload.each_with_index do |question, index|
      question.update_column(:position, index + 1) unless question.position == index + 1
    end
  end

  def question_params
    params.require(:conference_question).permit(:label, :question_type, :choices, :required, choice_options: [])
  end
end

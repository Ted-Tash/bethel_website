class ConferenceRegistrationsReport
  FILTERABLE_TYPES = %w[yes_no single_choice multiple_choice].freeze
  STATUSES = %w[active cancelled all].freeze

  attr_reader :conference, :search, :answer_filters, :status

  def initialize(conference, search: nil, answer_filters: {}, status: nil)
    @conference = conference
    @search = search.to_s.strip
    @status = status.to_s.in?(STATUSES) ? status.to_s : "active"
    @answer_filters = normalize_answer_filters(answer_filters)
  end

  def questions
    @questions ||= conference.questions.to_a
  end

  def filterable_questions
    questions.select { |question| question.question_type.in?(FILTERABLE_TYPES) }
  end

  def registrations
    @registrations ||= begin
      scope = apply_status(conference.registrations)
      scope = apply_search(scope) if search.present?
      scope = apply_answer_filters(scope)
      scope.includes(:answers).order(created_at: :desc, id: :desc)
    end
  end

  def response_counts
    @response_counts ||= begin
      counts = filterable_questions.to_h do |question|
        [ question.id, { options: question.available_options.index_with { 0 }, answered: 0, unanswered: 0 } ]
      end

      registrations.each do |registration|
        answers_by_question = registration.answers.index_by(&:conference_question_id)

        filterable_questions.each do |question|
          answer = answers_by_question[question.id]
          values = answer_values(question, answer)

          if values.empty?
            counts[question.id][:unanswered] += 1
          else
            counts[question.id][:answered] += 1
            values.each do |value|
              counts[question.id][:options][value] += 1 if counts[question.id][:options].key?(value)
            end
          end
        end
      end

      counts
    end
  end

  def filters_active?
    status != "active" || search.present? || answer_filters.any?
  end

  private

  def apply_status(scope)
    case status
    when "cancelled" then scope.cancelled
    when "all" then scope
    else scope.active
    end
  end

  def normalize_answer_filters(filters)
    submitted_filters = filters.to_h.stringify_keys

    filterable_questions.each_with_object({}) do |question, normalized|
      value = submitted_filters[question.id.to_s].to_s
      normalized[question.id.to_s] = value if value.in?(question.available_options)
    end
  end

  def apply_search(scope)
    escaped_search = ActiveRecord::Base.sanitize_sql_like(search.downcase)
    term = "%#{escaped_search}%"
    searchable_columns = %w[first_name last_name email phone].map do |column|
      "LOWER(conference_registrations.#{column}) LIKE :term ESCAPE '\\'"
    end
    searchable_columns << "LOWER(COALESCE(conference_answers.value, '')) LIKE :term ESCAPE '\\'"

    scope.left_outer_joins(:answers).where(searchable_columns.join(" OR "), term: term).distinct
  end

  def apply_answer_filters(scope)
    answer_filters.each do |question_id, value|
      question = questions.find { |item| item.id == question_id.to_i }
      matching_answers = ConferenceAnswer.where(conference_question_id: question.id)

      matching_answers = if question.question_type == "multiple_choice"
        filter_multiple_choice_answers(matching_answers, value)
      else
        matching_answers.where(value: value)
      end

      scope = scope.where(id: matching_answers.select(:conference_registration_id))
    end

    scope
  end

  def filter_multiple_choice_answers(scope, value)
    escaped_value = ActiveRecord::Base.sanitize_sql_like(value)
    scope.where(
      <<~SQL.squish,
        conference_answers.value = :value OR
        conference_answers.value LIKE :first ESCAPE '\\' OR
        conference_answers.value LIKE :middle ESCAPE '\\' OR
        conference_answers.value LIKE :last ESCAPE '\\'
      SQL
      value: value,
      first: "#{escaped_value}\n%",
      middle: "%\n#{escaped_value}\n%",
      last: "%\n#{escaped_value}"
    )
  end

  def answer_values(question, answer)
    return [] if answer.blank? || answer.value.blank?

    question.question_type == "multiple_choice" ? answer.selected_values : [ answer.value ]
  end
end

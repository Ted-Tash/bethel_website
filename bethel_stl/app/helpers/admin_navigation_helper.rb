module AdminNavigationHelper
  def admin_breadcrumbs
    trail = case controller_path
    when "admin/dashboard"
      return []
    when "admin/conferences"
      items = [ [ "Conferences", admin_conferences_path ] ]
      items << [ @conference.name, admin_conference_path(@conference) ] unless action_name == "index"
      items
    when "admin/conference_registrations"
      [
        [ "Conferences", admin_conferences_path ],
        [ @conference.name, admin_conference_path(@conference) ],
        [ "Registrations", admin_conference_registrations_path(@conference) ]
      ]
    when "admin/conference_questions"
      [
        [ "Conferences", admin_conferences_path ],
        [ @conference.name, admin_conference_path(@conference) ],
        [ @question.label, admin_conference_question_path(@conference, @question) ]
      ]
    when "admin/households"
      items = [ [ "Directory", admin_households_path ] ]
      case action_name
      when "new", "create"
        items << [ "New household", nil ]
      when "show", "edit", "update"
        items << [ @household.name, admin_household_path(@household) ]
        items << [ "Edit", nil ] if action_name.in?(%w[edit update])
      end
      items
    when "admin/contact_groups"
      items = [ [ "Messages", admin_messages_path ], [ "Contact groups", admin_contact_groups_path ] ]
      case action_name
      when "new", "create"
        items << [ "New group", nil ]
      when "show", "edit", "update"
        items << [ @contact_group.name, admin_contact_group_path(@contact_group) ]
        items << [ "Edit", nil ] if action_name.in?(%w[edit update])
      end
      items
    when "admin/recordings", "admin/recordings/documents"
      items = [ [ "Sermons", admin_recordings_path ] ]
      if action_name == "editor"
        items << [ "#{@recording.title} — Audio editor", nil ]
      elsif controller_path == "admin/recordings/documents"
        items << [ "Documents", nil ]
      elsif action_name.in?(%w[new create])
        items << [ "New sermon", nil ]
      elsif action_name != "index"
        items << [ @recording.title, nil ]
      end
      items
    when "admin/audio_extractions"
      items = [ [ "Audio Extractor", admin_audio_extractions_path ] ]
      if action_name.in?(%w[new create])
        items << [ "New extraction", nil ]
      elsif action_name == "show"
        items << [ @audio_extraction.display_name, admin_audio_extraction_path(@audio_extraction) ]
      end
      items
    when "admin/messages"
      items = [ [ "Messages", admin_messages_path ] ]
      if action_name.in?(%w[new create])
        items << [ "New message", nil ]
      elsif action_name == "show"
        items << [ "Message details", admin_message_path(@message) ]
      end
      items
    when "admin/profiles"
      [ [ "Edit profile", edit_admin_profile_path ] ]
    when "admin/events"
      [ [ "Events", admin_events_path ] ]
    when "admin/dummy"
      [ [ "Background jobs", nil ] ]
    else
      return []
    end

    home = current_user.super_admin? ? [ "Dashboard", admin_dashboard_path ] : [ "Conferences", admin_conferences_path ]
    trail.unshift(home) unless trail.first.last == home.last
    trail
  end

  def admin_back_destination(breadcrumbs)
    # Keep the conference list one tap away, even on nested conference pages.
    if controller_path.in?(%w[admin/conference_registrations admin/conference_questions])
      [ "Conferences", admin_conferences_path ]
    else
      breadcrumbs[-2]
    end
  end
end

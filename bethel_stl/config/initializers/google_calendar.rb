# =============================================================================
# Google Calendar Integration
# =============================================================================
#
# This app pulls upcoming events from a Google Calendar using the
# Google Calendar API v3 with a read-only API key (no OAuth required).
#
# SETUP STEPS:
#
# 1. Go to https://console.cloud.google.com/
# 2. Create a project (or select an existing one)
# 3. Enable the "Google Calendar API" under APIs & Services > Library
# 4. Create an API key under APIs & Services > Credentials
#    - Restrict the key to "Google Calendar API" only
# 5. Find your Calendar ID:
#    - In Google Calendar, go to Settings > [Your Calendar] > Integrate calendar
#    - Copy the "Calendar ID" (looks like: abc123@group.calendar.google.com)
#    - Make sure the calendar is PUBLIC or shared with the API
# 6. Add credentials to Rails:
#
#    EDITOR="code --wait" bin/rails credentials:edit
#
#    Then add:
#
#    google_calendar:
#      api_key: YOUR_GOOGLE_API_KEY
#      calendar_id: YOUR_CALENDAR_ID@group.calendar.google.com
#
# =============================================================================

# =============================================================================
# Twilio SMS Integration
# =============================================================================
#
# This app sends SMS messages to church members via the Twilio REST API.
#
# SETUP STEPS:
#
# 1. Sign up at https://www.twilio.com/
# 2. Get your Account SID and Auth Token from the Twilio Console dashboard
# 3. Buy or provision a phone number with SMS capability
#    - Go to Phone Numbers > Manage > Buy a number
# 4. Add credentials to Rails:
#
#    EDITOR="code --wait" bin/rails credentials:edit
#
#    Then add:
#
#    twilio:
#      account_sid: YOUR_ACCOUNT_SID
#      auth_token: YOUR_AUTH_TOKEN
#      phone_number: "+1XXXXXXXXXX"
#
# NOTES:
# - Phone number must be in E.164 format (e.g. +15551234567)
# - Twilio trial accounts can only send to verified numbers
# - SMS segments are 160 characters each; longer messages use multiple segments
# - Cost: ~$0.0079 per SMS segment (US numbers, as of 2024)
#
# =============================================================================

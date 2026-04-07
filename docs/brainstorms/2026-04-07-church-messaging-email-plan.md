# Church Messaging — Future Email Plan

**Date:** 2026-04-07
**Status:** Future lift (after SMS is live)
**Depends on:** SMS messaging feature being complete

## Overview

The SMS messaging feature is being built channel-agnostic on purpose. The `Message` model has a `channel` field, `MessageDelivery` tracks individual sends regardless of channel, and contact groups work for both phone and email. This doc outlines what's needed to add email as a second channel.

## What Already Exists (from SMS work)

- `Message` model with `channel` enum (`:sms` initially, `:email` to be added)
- `ContactGroup` + `ContactGroupMembership` for recipient lists
- `MessageDelivery` for per-recipient tracking
- `SendMessageJob` that dispatches based on channel
- Admin UI for composing, scheduling, and sending messages
- Member model with `email` field already present

## What Needs to Be Built

### 1. Email Delivery Service

Option A: **SendGrid** (via `sendgrid-ruby` gem)
- Transactional email API, similar to Twilio SMS pattern
- SendGrid is owned by Twilio, so credentials/billing may already be linked
- Good for bulk sends with tracking

Option B: **Action Mailer + SMTP**
- Rails built-in, no extra gem
- Could use SendGrid SMTP relay, Gmail SMTP, or any provider
- Simpler but less delivery tracking

**Recommendation:** Start with Action Mailer + SendGrid SMTP relay. Simple to set up, gives us deliverability of SendGrid without a heavy SDK dependency. Can upgrade to the API later if we need open/click tracking.

### 2. Credentials

```yaml
# In Rails credentials
sendgrid:
  api_key: SG.xxxxx
  # OR for SMTP relay:
  smtp_username: apikey
  smtp_password: SG.xxxxx
  from_address: "church@bethelstl.org"
```

### 3. Message Model Changes

- Add `:email` to the `channel` enum
- Add `subject` field to `Message` (required for email, not used for SMS)
- Consider adding `:both` channel option to send same content via SMS and email simultaneously

### 4. Admin UI Changes

- Channel selector on the message form (SMS / Email / Both)
- When email is selected, show a `subject` field
- Body field: for email, could support markdown or a simple rich text editor (Action Text / Trix is already in Rails 8)
- Preview button to see how the email will render

### 5. Email Template

- Simple, clean HTML email template
- Church branding (logo, colors)
- Plain text fallback (auto-generated from body)
- Unsubscribe link (required by CAN-SPAM)

### 6. Member Model Changes

- Add `email_opted_out` boolean (CAN-SPAM compliance — email legally requires unsubscribe)
- Filter recipients: only send to members where `email.present? && !email_opted_out?`

### 7. SendMessageJob Update

The job already checks `message.channel` — just add the email branch:

```ruby
case message.channel
when "sms"
  TwilioSmsService.send(to: delivery.phone_or_email, body: message.body)
when "email"
  ChurchMailer.blast(delivery).deliver_now
when "both"
  # Create two deliveries per member, one per channel
end
```

## Cost Considerations

- SendGrid free tier: 100 emails/day (plenty for a small church)
- Paid plans start at ~$20/mo for 50k emails if needed
- Alternatively, a basic SMTP provider works fine at this scale

## Open Questions

1. Rich text or plain text for email body? (Trix editor is free with Rails)
2. Do we want open/click tracking? (Requires SendGrid API, not just SMTP)
3. Same body for SMS and email when sending to "Both"? Or separate fields?
4. Email-specific groups vs. reusing the same contact groups?

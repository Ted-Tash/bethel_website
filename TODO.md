# Bethel Website To-Do

- [x] Add Kent and Nicole's photo (have the photo already)
- [x] Update summer schedule & add flash banners (task created)
- [ ] Remove the Pinecrest registration modal and its temporary date-gating code after September 14, 2026.

## Conference Registrations

### Extend mass messaging to conference registrants

Allow conferences to be selected as recipient groups in the existing SMS/email mass-messaging interface. Conference registrants must remain separate from church member records.

#### Requirements

- [ ] Automatically expose every conference as a system-managed messaging group.
- [ ] Use the conference's current registrations as a live recipient list.
- [ ] Use a registration's phone number for SMS and email address for email.
- [ ] Clearly distinguish conference groups from manually managed contact groups.
- [ ] Do not allow recipients to be manually added to or removed from conference groups.
- [ ] Do not create `Member` records or ordinary contact-group memberships for registrants.
- [ ] Record message deliveries against either a `Member` or a `ConferenceRegistration`.
- [ ] Normalize and deduplicate phone numbers or email addresses before sending.
- [ ] Preserve delivery statuses and failure reporting.
- [ ] Keep the “Everyone” recipient option limited to church members unless intentionally changed later.

#### Acceptance criteria

- [ ] An admin can select a conference from the message recipient selector.
- [ ] Messages go to the conference's registrations that exist when the message is sent.
- [ ] New registrations are automatically included in future messages.
- [ ] Duplicate normalized phone numbers or email addresses receive only one copy of a message.
- [ ] Delivery history identifies the conference registration recipient.
- [ ] Existing member contact groups continue to work unchanged.
- [ ] Tests cover SMS and email recipient selection, deduplication, and delivery records.

### Notify admins of new conference registrations

Send an email notification to every admin user after a public conference registration is successfully submitted. Do not send a confirmation email to the registrant; the existing thank-you page remains their confirmation.

#### Requirements

- [ ] Enqueue an admin notification email after a `ConferenceRegistration` is successfully saved.
- [ ] Send one notification to every record in `User.all`.
- [ ] Deliver notifications asynchronously with `deliver_later`.
- [ ] Do not let an email delivery failure prevent or roll back registration.
- [ ] Include the conference name, registrant's name, submission time, and a link to the authenticated admin registration page.
- [ ] Keep detailed registration answers behind the authenticated admin link instead of including them in email.
- [ ] Do not email the registrant.

#### Acceptance criteria

- [ ] Every existing `User` receives one notification after a successful public registration.
- [ ] No notification is sent when registration validation fails.
- [ ] No email is sent to the registrant.
- [ ] The email links directly to the admin registration details.
- [ ] Registration succeeds even if asynchronous email delivery later fails.
- [ ] Tests cover successful registration, invalid registration, multiple users, and the absence of a registrant email.

### Finish SMS and email delivery setup

Current audit: Twilio SMS is implemented, has a complete local credential set, and has successfully delivered development messages. Resend is not installed or configured. The mass-message job currently ignores its channel and always sends SMS through Twilio. Production SMS also depends on Fly.io running the Solid Queue worker, which has not been verified.

- [ ] Add and configure Resend for Action Mailer in development and production.
- [ ] Store the Resend API key securely without committing it to the repository.
- [ ] Replace `from@example.com` with a verified sender address.
- [ ] Replace the production mailer host `example.com` with the real application host.
- [ ] Implement actual email delivery for messages whose channel is `email`.
- [ ] Ensure SMS messages continue to use Twilio and email messages use Resend.
- [ ] Add development email preview or sandbox behavior so emails can be tested safely.
- [ ] Add or verify the Fly.io configuration, including `RAILS_MASTER_KEY` and persistent SQLite storage.
- [ ] Ensure Solid Queue runs in production, such as by enabling `SOLID_QUEUE_IN_PUMA` on the single Fly.io machine.
- [ ] Perform end-to-end development and production smoke tests for both SMS and email.
- [ ] Add tests proving each channel invokes the correct delivery service and records successes and failures.

### Conference registration reporting and export

CSV remains the low-resource spreadsheet export and can be opened or imported by Excel and Google Sheets. Direct Google Sheets integration was intentionally omitted to avoid Google API credentials, permissions, and verification.

- [x] Provide a spreadsheet-style per-conference admin table with one column per registration question.
- [x] Search registrations by name, email, phone, or answer.
- [x] Filter registrations by yes/no and choice-question responses.
- [x] Show response totals for yes/no and choice questions based on the currently filtered registrations.
- [x] Export all registrations or the currently filtered registrations as spreadsheet-safe CSV.
- [x] Let admins cancel and reactivate registrations without deleting retained registration data.

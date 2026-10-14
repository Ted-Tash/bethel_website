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

Current audit: Twilio has a complete local credential set and history of two provider-accepted SMS sends, not confirmed handset delivery. Resend's official Rails SDK, channel routing, composer, HTML/text templates, safe local capture, consent and address-wide unsubscribe suppression are implemented. Delivery specs were removed at the user's request. Shared `config/credentials.yml.enc` and the existing master-key setup are unchanged; Resend secrets/sender have not been provisioned. Production is self-hosted via Kamal, not Fly.io. Source declares runtime `RAILS_MASTER_KEY`, a persistent storage volume and `SOLID_QUEUE_IN_PUMA`; live health/delivery remains unverified. See [email provisioning and readiness guide](docs/email-delivery.md).

- [x] Add and configure Resend for Action Mailer in development and production (code; live provisioning pending).
- [ ] Store the real Resend API key in shared encrypted Rails credentials alongside existing secrets.
- [x] Remove `from@example.com` and read the live sender from credentials; fail explicitly if absent.
- [ ] Provision and verify the actual sender/domain and church postal address.
- [x] Remove production `example.com` and require `MAILER_HOST` for live email links.
- [ ] Set and verify the real production hostname/HTTPS in the actual Kamal deployment.
- [x] Implement actual email delivery for messages whose channel is `email` (mocked provider verification only).
- [x] Ensure SMS messages continue to use Twilio and email messages use Resend.
- [x] Add channel/subject UI, server-side subject validation and normalized/deduplicated email destinations.
- [x] Add safe default development file capture, explicit live opt-in, and distinct captured results (sample preview removed at the user's request).
- [x] Add permission controls and signed confirmation/one-click unsubscribe with persistent address-wide suppression.
- [ ] Verify Kamal runtime key injection and persistent SQLite/queue storage in production.
- [ ] Verify live Solid Queue supervisor/dispatcher/worker and continuously running host for timed jobs.
- [ ] Perform approved end-to-end development and production smoke tests for both SMS and email.
Delivery specs are intentionally omitted at the user's request; use the documented controlled manual checks.

### Conference registration reporting and export

CSV remains the low-resource spreadsheet export and can be opened or imported by Excel and Google Sheets. Direct Google Sheets integration was intentionally omitted to avoid Google API credentials, permissions, and verification.

- [x] Provide a spreadsheet-style per-conference admin table with one column per registration question.
- [x] Search registrations by name, email, phone, or answer.
- [x] Filter registrations by yes/no and choice-question responses.
- [x] Show response totals for yes/no and choice questions based on the currently filtered registrations.
- [x] Export all registrations or the currently filtered registrations as spreadsheet-safe CSV.
- [x] Let admins cancel and reactivate registrations without deleting retained registration data.

# Congregation email delivery (Resend + Action Mailer)

## Implementation and limits

The official `resend` Ruby/Rails SDK (1.17.x) supplies the Action Mailer adapter. `ResendCheckedDelivery` adds an acceptance-ID check because the SDK adapter can return a response without raising. SMS still goes through `TwilioSmsService`; email uses `ResendEmailService` and `MemberMessageMailer`. Each message is processed sequentially with batched SQLite recipient reads, not one extra job/process per recipient. Solid Queue serializes mass-message jobs with a one-hour concurrency lease; live Resend requests wait 0.6 seconds each to stay below its default two requests/second. Scheduled times are earliest eligibility times, not guaranteed execution times if another bulk job is running. Groups and Everyone remain limited to members, not conference registrants.

New members are enabled for email by default (`Member.email_consent`, true by default). There is no consent checkbox in the household form, and email changes no longer reset this flag. Existing false values are preserved by the default-change migration and remain excluded from email; any backfill requires a separately approved operator action. This default is an application setting, not evidence of recipient permission. Addresses are trimmed, downcased, deduplicated per message, and validated; invalid addresses are failed deliveries.

Both templates include unsubscribe links and the church's actual postal address. A GET only displays confirmation (safe for link scanners); a signed, purpose-scoped POST suppresses the entire normalized address, including duplicate/future contacts and future scheduled messages. RFC 8058 one-click headers use the same POST. No authentication is required; CSRF is bypassed only for this suppression action because the token is its authorization. Tokens do not expire so old messages still allow opting out. Treat links/access logs as private: tokens authorize suppression and include signed address data. Keep `secret_key_base` stable; rotating it invalidates existing links.

Suppression survives contact deletion. Permission alone does not remove it. There is deliberately no public resubscribe endpoint. Only remove an `EmailSuppression` after an operator verifies a fresh recipient request and records that permission externally. Opt-outs do not affect SMS. Suppression and a postal footer are safeguards, **not a legal-compliance certification**: applicability of CAN-SPAM, other local laws, Resend's acceptable-use rules, and consent requirements must be reviewed by the church before congregation-wide sends. Maintain evidence of permission separately; default email eligibility is not a consent audit.

### Result meanings

- `sent` / Accepted: Twilio or Resend accepted the API request. `provider_id` stores the SID/email ID; legacy `delivered_at` means acceptance time, not confirmed delivery.
- `captured`: local file or test-mailbox capture only; never increments `sent_count`.
- `failed`: invalid destination, missing configuration, or delivery exception. Email provider exceptions record the exception class rather than potentially sensitive response bodies.
- `skipped`: member email disabled or address suppressed before sending.
- Message counts include each of these; some accepted deliveries yield overall `sent` even with failures. Review all counts, not just the overall status. No eligible recipients is an explicit message error.

A cancelled or already claimed job does not send. Claim/cancel are atomic SQLite updates, with no write transaction held across network calls. Crashed/interrupted jobs are not blindly resumed (SMS lacks an idempotency key); pending deliveries must be reconciled with the provider before any resend. Ordinary provider failures are recorded and not automatically retried. Resend requests carry a stable per-delivery idempotency key, but a newly composed message has new delivery IDs. Check provider logs before retrying ambiguous failures. Inbox/handset delivery, bounce/complaint webhooks and automatic provider suppression synchronization are not implemented. Monitor provider dashboards and manually suppress reported hard bounces/complaints before the next send.

## Shared encrypted credentials — keep the current master key

**Use only `bethel_stl/config/credentials.yml.enc` and the existing `config/master.key`.** No environment-specific credentials, migration, key rotation, or new secrets were provisioned in this task. Existing Twilio/Google/other secrets remain untouched. Development capture works without any Resend secrets.

From `bethel_stl/`, after obtaining an authorized Resend key and verified sender privately, edit with a trusted local editor:

```sh
mise exec -- env EDITOR='your-trusted-editor --wait' bin/rails credentials:edit
```

Do not use `credentials:show`, paste secrets in chat, put keys in shell arguments, or replace the whole document. Add this structure **alongside** all existing keys (the descriptions below are placeholders, not usable values):

```yaml
resend:
  api_key: <real privately provisioned Resend API key>
  from_address: <actual verified sender, optionally Name <address>>
  postal_address: <actual church mailing address for the footer>
```

Preserve `secret_key_base`, `twilio.account_sid`, `twilio.auth_token`, `twilio.phone_number`, and all Google/other keys. Confirm only encrypted ciphertext changes are staged. Key files are ignored by Git and Docker; never add plaintext credentials or a literal key to `.kamal/secrets`.

Missing live API key/sender, postal address, or hostname produces failed delivery records. Disabled delivery or suppressed errors also fails explicitly rather than pretending to send. Secretless image builds can boot because credential validation happens at delivery time.

## Development: safe capture first

Default development delivery is Action Mailer's `:file` adapter in ignored `bethel_stl/tmp/mail_capture/`. Sender is an intentionally invalid preview address; live credentials are not required. Rails' file adapter groups/appends captured mail by destination; inspect the local file with a mail viewer, and clean it up when finished because it contains private message data. It is not a shared or durable delivery archive.

- Composer (existing admin login): http://localhost:4000/admin/messages/new
- History: http://localhost:4000/admin/messages
- Jobs: http://localhost:4000/admin/jobs

Safe local QA:

1. From `bethel_stl/`, run `mise exec -- bin/rails db:prepare`, then your normal web process **without** `ALLOW_REAL_EMAIL_DELIVERY`.
2. Create a dedicated group with only a test member (`example.invalid` is suitable for capture), no phone number, and email enabled (the default for new members). Select **Email**, supply subject/body, and send to that group, not Everyone. Start `mise exec -- bin/jobs` without live-email opt-in if no local worker is already running. **Starting a worker processes other queued jobs too: first inspect/cancel stale jobs, especially SMS, which is still live.**
3. Verify `captured`, zero accepted sends, captured MIME output and counts. Inspect HTML/plain text, escaped body, subject, footer and unsubscribe link in the captured email. Schedule another email, cancel it, and verify no delivery. Unsubscribe via its local confirmation page, then send another capture to the same group: it must be skipped. Confirm missing subject is rejected server-side.

No QA contacts were inserted by this task. Existing login secrets were not inspected.

### Explicit live development smoke test — requires separate approval

After approval, securely provision the shared credentials and use a single consenting operator-controlled address in an isolated group. Review/cancel **all outstanding scheduled emails first**; a worker restarted in live mode would deliver them. Never use Everyone for a smoke test.

Both the web process (if needed) and the job worker that actually sends must opt in:

```sh
ALLOW_REAL_EMAIL_DELIVERY=true mise exec -- bin/rails server
ALLOW_REAL_EMAIL_DELIVERY=true mise exec -- bin/jobs
```

The value must be exactly `true`. These are separate long-running processes (run in separate terminals); do not start duplicate workers. Shared Resend credentials by themselves never enable development sending; changing only the adapter is also rejected. Restart all processes **without** this flag afterward. If testing publicly usable unsubscribe links, configure an approved reachable development `MAILER_HOST`/`PORT`; ordinary development links use localhost:4000 and HTTP. Production links always use HTTPS. Send one email only, check acceptance ID in history/Resend, then independently confirm receipt, text/HTML and opt-out. A provider acceptance ID alone is not delivery proof. SMS has no new capture safeguard: only test it after separate explicit approval, using one controlled handset.

## Production readiness — self-hosted Kamal, not Fly.io

The user clarified that old Fly.io guidance was stale. There is no `fly.toml` and none is needed for this deployment. Checked-in `bethel_stl/config/deploy.yml` declares:

- `RAILS_MASTER_KEY` under `env.secret`; existing `.kamal/secrets` sources the ignored local `config/master.key` into it (retain that setup).
- `SOLID_QUEUE_IN_PUMA: true` (Puma's Solid Queue plugin is already present).
- named volume `bethel_stl_storage:/rails/storage`, containing production primary/queue/cache/cable SQLite databases and local uploads.

These are **source declarations, not verified production health**. The checked-in deployment host/registry/proxy also contain template settings; confirm the actual deployment overlays/targets with the operator. No deploy, account/DNS changes, or production inspection occurred.

Before approving deployment/congregation-wide mail:

- [ ] Privately provision Resend API key with appropriate sending permissions; use a sender in a verified Resend domain. Never guess a sender or use the preview address.
- [ ] With explicit approval, add Resend's exact DNS verification/SPF/DKIM records and an appropriate DMARC policy at the authoritative DNS provider. Do not overwrite existing SPF/MX records casually or proxy mail DNS records. Wait for Resend verification; check sender/reply handling and provider plan, daily/monthly limits and rate limits. Mass jobs are serialized and live calls paced, but other applications sharing the same Resend account can still consume its quota; review limits and reduce batches as needed. Extremely long jobs exceeding the one-hour concurrency lease require operator review. Rate-limit responses are tracked failures, not silently retried.
- [ ] Add the shared credential values above; retain the existing master key and all other secrets. The encrypted file ships in the image, but the key must be injected at **runtime**. Verify Kamal resolves `RAILS_MASTER_KEY` privately without logging it. Do not add plaintext build args/secrets or literal keys to tracked `.kamal/secrets`.
- [ ] Set `MAILER_HOST` in the actual Kamal deployment's `env.clear` to the real public hostname only (no scheme/path/port). No hostname was guessed in source. Configure working HTTPS and the real proxy hostname; unauthenticated unsubscribe GET/POST must be reachable and not blocked by CDN/WAF/login challenges. Follow the deployment's actual SSL termination scheme.
- [ ] Back up persistent SQLite before the migration, deploy only with approval, run/verify `db:prepare`, and confirm the new consent/suppression/results schema. New members default to email enabled after the default-change migration; existing false values are unchanged. Review existing eligibility separately before any approved backfill.
- [ ] Verify the storage volume really mounts at `/rails/storage`, is writable by the container user, persists across container replacements, and has tested off-host backups (including queue DB and suppression records). Use a single host; do not add Postgres or distribute SQLite across machines.
- [ ] Verify a live Solid Queue supervisor, worker **and dispatcher** with recent heartbeats, no backlog/failed jobs, and a timed controlled job. `SOLID_QUEUE_IN_PUMA` being configured alone is not evidence. Do not start a second duplicate supervisor casually.
- [ ] Keep the self-hosted machine/container running continuously for timed jobs; check restart policy, resource limits, time/timezone and monitoring. There is no Fly machine auto-stop setting to configure. Defaults use one job process and three threads; start small, measure RSS under Puma + queue + existing audio jobs, and avoid extra web/job processes. Consider Solid Queue's documented async Puma mode if measured memory requires it; no untested topology change was made here.
- [ ] Review consent records, postal address, unsubscribe/one-click behavior, privacy/retention and applicable law/provider rules. Establish an operator process for bounces/complaints, manual suppression and verified reconsent. This task alone does not certify bulk-email readiness.

### Controlled production smoke test — only after deployment/send approval

1. Inspect stale scheduled/pending jobs before enabling the deployment. Use an isolated group with one operator-controlled, consenting recipient, not Everyone.
2. Send one immediate email; check accepted ID and provider dashboard, then independently verify inbox receipt and both MIME parts. Test unsubscribe and a second explicitly approved attempt: it should produce `skipped`, no provider call. Do not count a skipped attempt as a delivery.
3. Schedule one email a few minutes ahead to another approved, unsuppressed test address. Keep the machine running; verify dispatcher/worker and acceptance/receipt after the scheduled time. Schedule/cancel another and confirm zero delivery.
4. Separately authorize a one-handset SMS smoke test, check Twilio acceptance SID and independent handset receipt. Prior local history had **two Twilio-accepted sends, not confirmed handset delivery**.
5. Record evidence separately for API acceptance, receipt and timing; review failed/pending deliveries without blindly resending. No live delivery was verified by this implementation.

## Verification

Delivery tests and test-only dependency/fixture changes were removed at the user's request. No delivery specs are included. The sample email preview was also removed at the user's request; safe local file capture remains available.

From `bethel_stl/`, `mise exec -- bin/rails zeitwerk:check` checks application loading. Use the controlled manual checks above for delivery behavior; loading/lint checks cannot establish production infrastructure or live deliverability.

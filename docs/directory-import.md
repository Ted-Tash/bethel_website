# Encrypted directory import

`bethel_stl/lib/tasks/directory_import.rake` contains the complete reviewed dataset
as authenticated **AES-256-GCM ciphertext**, not readable personal information.
The dataset contains **29 households and 87 members**. Running the task needs no
XLSX, new gems, `require` statements, separate data file, or network access.

## Encryption and deployment

The task decrypts its embedded snapshot in memory using
`Rails.application.credentials.dig(:directory_import, :key)`. This dedicated,
random 256-bit key is stored in the existing shared `config/credentials.yml.enc`.
The existing master key and all pre-existing credential values remain unchanged;
there are no environment-specific credential files or new server-side secrets.
The ciphertext uses the purpose `directory-import-v1` and a JSON serializer.

Deploy **both the task and the updated encrypted credentials**. Production's
existing `RAILS_MASTER_KEY` unlocks the shared credentials and hence the import
key. The command does not change. Never copy a master key or the decrypted import
key into source, shell history, deployment logs, or a public issue. Wrong/missing
keys and modified ciphertext fail before any database changes.

Anyone with access to the master key can decrypt the embedded snapshot. Encryption
does not replace access control, key protection, or recipient-consent review.
Never commit a plaintext version, even temporarily: deleting it later does not
remove it from git history. Do not put any personal directory details in docs.

## Local QA

Run commands from `bethel_stl/` (prefix with `mise exec --` if needed).

```sh
# Preview only; no database changes.
bin/rails directory:import REPLACE=1

# Back up the database, then replace the development directory.
bin/rails directory:import REPLACE=1 APPLY=1

# Verify rerun behavior: all 29 households should say SKIP.
bin/rails directory:import
```

Browse `/admin/households` using an existing super-admin login. No accounts or
passwords are created or changed by this task.

`REPLACE=1` is permitted only against this app's standard
`storage/development.sqlite3` database, never production. It destroys existing
households/members, removes their contact-group memberships, and clears member
links on historical message deliveries. Contact groups, messages, delivery
history, suppressions, accounts, and other app data remain intact. Old group
memberships are not automatically assigned to newly imported people.

## Production, after local QA and deployment approval

Do not copy the workbook to production. Run these **inside the deployed app**:

```sh
# Preview first.
RAILS_ENV=production bin/rails directory:import

# After reviewing the preview and obtaining production approval.
RAILS_ENV=production bin/rails directory:import APPLY=1 CONFIRM_PRODUCTION=1
```

If the deployed shell already sets `RAILS_ENV=production`, the apply command is:

```sh
bin/rails directory:import APPLY=1 CONFIRM_PRODUCTION=1
```

Normal imports add missing families and skip families whose full household and
member data already exactly match. Partial matches, changed data, or matching
members spread across existing households block the entire import instead of
silently overwriting or duplicating people. Resolve those cases before rerunning;
there is no production replacement switch. Same-name people are not inferred to
be different people, and shared addresses/email/phone values are not used to guess
identity.

The task refuses changes that could alter scheduled/sending message audiences.
It does not send messages, enqueue jobs, or modify login accounts.

## Backups, reports, and rollback

Before applying, the task makes a consistent SQLite `VACUUM INTO` backup at:

```text
storage/directory_imports/<timestamp>/before.sqlite3
```

Each preview/apply also writes `report.json` in its own timestamped directory,
with the source submission IDs, decrypted planned records, actions, and conflicts.
Backups/reports are **not encrypted by this task**: directories are `0700`, files
are `0600`, gitignored, and on the app's persistent storage volume. Console output
also contains personal information. Keep storage, terminal output, and collected
logs private; do not publish them or attach them to public issues.

Applying the dataset is one transaction: any database error rolls back all
directory changes. The report records whether that transaction applied or rolled
back. For a later manual restore, stop the app and workers and use the normal
SQLite backup restore procedure. This backup is the **whole primary database**;
restoring it also reverses unrelated changes made after the backup. Do not overwrite
a live SQLite file or leave mismatched WAL/SHM files in place. Never run a schema
reset or `db:reset` as part of this import.

## Reviewed transformations

The encrypted snapshot already includes the operator-approved corrections:

- Combine same-person primary/additional-member duplicates and repeat submissions.
- Apply the explicitly confirmed contact correction.
- Merge the approved overlapping family submissions, retaining individual contacts.
- Omit the test submission, placeholder person, compound-name entry, and rejected
  alias/extra-person entries; retain the confirmed individual members instead.
- For minors marked `ChildPhoneOrEmail=No`, omit phone/email without omitting the
  child, including three cases of copied parental contact information.
- Trim whitespace, lowercase email, normalize US phones to `+1...`, use MO/IL,
  and combine apartment/address line 2 into the street field.
- Preserve separate submissions at shared addresses unless a merge was approved.
- Birthdates, ages, consent metadata, and submission dates have no corresponding
  directory columns and are not persisted. The import grants no messaging consent
  or permissions beyond what the application already supports.

## Contact coverage

Using the spreadsheet's own Under18 flags, not inferred ages:

- 57 adults: 52 with both phone/email, one with phone only, four with neither.
- 30 minors: three with both phone/email, 27 without either after the reviewed
  removal of copied parent contacts.
- Every household has at least one phone and email.

The form's age flags may contain mistakes; these figures describe the submitted
flags, not verified ages. The task does not add age fields to the member model.

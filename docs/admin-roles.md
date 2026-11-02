# Admin roles

- **Super admin** (`super_admin`): access to all admin features, including the jobs dashboard.
- **Conference manager** (`conference_manager`): access to every conference, registration question, and registration (including exports, cancellation, and reactivation). Can also edit their own sign-in email/password. Other admin features are forbidden on the server and hidden in navigation.

## Console-only management

Roles are managed exclusively through the **production Rails console**. Do not add a user/role management UI or HTTP endpoints, including for super admins. Profile updates cannot change roles. New accounts default to conference manager.

In the production console:

```ruby
user = User.find_by!(email: "person@example.com")
user.update!(role: :conference_manager)
# To grant full access instead:
user.update!(role: :super_admin)
```

Changes take effect on the user's next request, including existing sessions. Keep at least one super admin when changing roles; the console permits demoting your own account.

Conference notification recipients (`ConferenceAdmin` email addresses) are separate from login accounts and do not grant permissions.

## Migration

`bethel_stl/db/migrate/20260822000000_add_roles_to_users.rb` replaces the old `admin` boolean with a validated, non-null `role`. It explicitly runs `UPDATE users SET role = 'super_admin'` for **all existing accounts**, regardless of their previous admin flag. Later accounts default to `conference_manager`.

Run the normal Rails database migrations as part of deployment. The backfill runs only when this migration is first applied; it does not re-promote users on subsequent deployments. A rollback maps super admins to the old `admin = true` flag and conference managers to `admin = false`.

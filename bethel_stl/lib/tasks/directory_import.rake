namespace :directory do
  desc "Preview the reviewed directory import; APPLY=1 saves, REPLACE=1 replaces development directory only"
  task import: :environment do
    # Self-contained, authenticated AES-256-GCM ciphertext: no XLSX, extra gems,
    # requires, or external services. Never put the plaintext directory in git.
    # The matching key lives in shared Rails encrypted credentials, unlocked by
    # the existing master key in both development and production.
    encrypted_data = <<~ENCRYPTED.delete("\n")
      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
      uAYjNEjVwtT2jmK0BBeBvWSZdydKG/T1Nh3Q3w==--tg6QKTJAwMBQOcgn--Z9oIroIEfjIcKDGJwcjG8A==
    ENCRYPTED

    key = Rails.application.credentials.dig(:directory_import, :key).to_s
    abort "Missing/invalid directory_import.key in shared Rails credentials" unless key.match?(/\A[0-9a-f]{64}\z/)
    begin
      encryptor = ActiveSupport::MessageEncryptor.new([ key ].pack("H*"), cipher: "aes-256-gcm", serializer: JSON)
      decrypted = encryptor.decrypt_and_verify(encrypted_data, purpose: "directory-import-v1")
      abort "Directory payload has an invalid purpose" unless decrypted
      households = decrypted.map(&:symbolize_keys)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      abort "Cannot decrypt the directory payload; verify the deployed credentials and import key"
    end

    apply = ENV["APPLY"] == "1"
    replace = ENV["REPLACE"] == "1"
    connection = ActiveRecord::Base.connection
    abort "This import requires SQLite" unless connection.adapter_name == "SQLite"
    database = Pathname.new(ActiveRecord::Base.connection_db_config.database).expand_path(Rails.root)
    if replace && !(Rails.env.development? && database == Rails.root.join("storage/development.sqlite3").expand_path)
      abort "REPLACE=1 is only allowed on this app's standard development database, never production"
    end
    if apply && Rails.env.production? && ENV["CONFIRM_PRODUCTION"] != "1"
      abort "Production writes require APPLY=1 CONFIRM_PRODUCTION=1 after reviewing the preview"
    end

    member_fields = %w[first_name last_name phone email]
    household_fields = %w[name street city state zip]
    normalized_name = ->(first, last) { "#{first} #{last}".squish.downcase }
    members = households.flat_map { |household| household[:members] }
    errors = []
    errors << "Expected the reviewed snapshot of 29 households / 87 members" unless households.size == 29 && members.size == 87
    duplicate_names = members.group_by { |member| normalized_name.call(member["first_name"], member["last_name"]) }.select { |_name, rows| rows.size > 1 }.keys
    errors << "Duplicate member names: #{duplicate_names.join(', ')}" if duplicate_names.any?
    members.each do |member|
      name = "#{member['first_name']} #{member['last_name']}"
      errors << "Invalid phone for #{name}" if member["phone"].present? && !member["phone"].match?(/\A\+1\d{10}\z/)
      errors << "Invalid email for #{name}" if member["email"].present? && !member["email"].match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
    end

    # Capture directory-related rows so changes during preview/backup cannot be overwritten.
    snapshot = lambda do
      [ Household.order(:id).map(&:attributes), Member.order(:id).map(&:attributes),
        ContactGroupMembership.order(:id).map(&:attributes),
        MessageDelivery.order(:id).pluck(:id, :member_id, :status), Message.order(:id).pluck(:id, :status) ]
    end
    before = snapshot.call
    existing = Household.includes(:members).order(:id).to_a
    plan = households.map do |household|
      attributes = household.stringify_keys.slice(*household_fields)
      record = Household.new(attributes)
      household[:members].each { |member| record.members.build(member) }
      errors << "#{household[:name]}: #{record.errors.full_messages.join(', ')}" unless record.valid?
      record.members.each do |member|
        errors << "#{member.full_name}: #{member.errors.full_messages.join(', ')}" unless member.valid?
      end
      errors << "Empty household: #{household[:name]}" if record.members.empty?

      # Never guess identities or overwrite existing data on a normal rerun.
      # Exact existing families are skipped; partial/changed matches block the entire import.
      # A shared address/surname alone does not make separate submissions the same family.
      candidates = replace ? [] : existing.select do |candidate|
        candidate.members.any? do |member|
          household[:members].any? do |incoming|
            normalized_name.call(member.first_name, member.last_name) == normalized_name.call(incoming["first_name"], incoming["last_name"])
          end
        end
      end
      exact = candidates.one? && candidates.first.attributes.slice(*household_fields) == attributes &&
        candidates.first.members.map { |member| member.attributes.slice(*member_fields) }.sort_by(&:to_json) == household[:members].sort_by(&:to_json)
      action = if candidates.empty?
        "create"
      elsif exact
        "skip"
      else
        errors << "#{household[:name]} (source #{household[:source_ids].join('/')}): existing household(s) #{candidates.map(&:id).join(', ')} differ; resolve manually, no automatic overwrite"
        "conflict"
      end
      { action: action, source_ids: household[:source_ids], attributes: attributes, members: household[:members], existing_ids: candidates.map(&:id) }
    end
    if plan.any? { |item| item[:action] == "create" } && Message.where(status: [ "scheduled", "sending" ]).exists?
      errors << "Resolve scheduled/sending messages before changing the directory; their recipient lists could change"
    end

    puts "#{apply ? 'APPLY' : 'PREVIEW'} | #{Rails.env} | #{database}"
    puts "Reviewed data: #{households.size} households, #{members.size} members"
    puts "Contacts: #{members.count { |member| member['phone'].present? }} with phone; #{members.count { |member| member['email'].present? }} with email"
    if replace
      puts "REPLACE: remove #{Household.count} households / #{Member.count} members first"
      puts "Also removes #{ContactGroupMembership.count} directory group memberships and clears #{MessageDelivery.where.not(member_id: nil).count} historical delivery member links; groups/messages/delivery history remain"
    end
    plan.each do |item|
      puts "#{item[:action].upcase.ljust(8)} #{item[:attributes]['name']} | #{item[:attributes]['street']} | #{item[:members].size} members"
    end

    # Backups and reports contain private information; keep them off git and public URLs.
    artifact_directory = Rails.root.join("storage/directory_imports", Time.current.utc.strftime("%Y%m%dT%H%M%S.%6N"))
    FileUtils.mkdir_p(artifact_directory, mode: 0o700)
    report_path = artifact_directory.join("report.json")
    report = { environment: Rails.env, database: database.to_s, apply: apply, replace: replace,
      status: errors.any? ? "blocked" : "preview", errors: errors, plan: plan }
    write_report = -> { File.open(report_path, "w", 0o600) { |file| file.write(JSON.pretty_generate(report)) } }
    write_report.call
    puts "Report: #{report_path}"
    abort errors.join("\n") if errors.any?
    unless apply
      puts "No database changes. Add APPLY=1 to save#{replace ? ' this replacement' : ''}."
      next
    end

    # VACUUM INTO makes a consistent SQLite backup, including committed WAL data.
    # Unlike copying the .sqlite3 file, this is safe while the app is running.
    backup_path = artifact_directory.join("before.sqlite3")
    old_umask = File.umask(0o077)
    begin
      connection.execute("VACUUM INTO #{connection.quote(backup_path.to_s)}")
    ensure
      File.umask(old_umask)
    end
    report[:backup] = backup_path.to_s
    puts "Backup: #{backup_path}"

    begin
      Household.transaction do
        raise "Directory or message state changed during planning; rerun the preview" unless snapshot.call == before
        Household.find_each(&:destroy!) if replace
        plan.each do |item|
          next if item[:action] == "skip"
          household = Household.new(item[:attributes])
          item[:members].each { |member| household.members.build(member) }
          household.save!
          item[:household_id] = household.id
          item[:member_ids] = household.members.map(&:id)
        end
      end
      report[:status] = "applied"
    rescue StandardError => error
      report[:status] = "rolled_back"
      report[:error] = error.message
      raise
    ensure
      write_report.call
    end
    puts "Done: #{plan.count { |item| item[:action] == 'create' }} households created, #{plan.count { |item| item[:action] == 'skip' }} already imported."
    puts "Directory now contains #{Household.count} households / #{Member.count} members. No messages sent or login accounts changed."
  end
end

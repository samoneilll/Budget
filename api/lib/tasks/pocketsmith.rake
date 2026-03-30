namespace :pocketsmith do
  desc "Sync recent transactions from PocketSmith and run Claude categorisation"
  task sync: :environment do
    days = ENV.fetch("DAYS_BACK", 30).to_i
    puts "[#{Time.now}] Syncing #{days} days of transactions..."
    PocketsmithSyncService.new.sync_transactions(days_back: days)
    puts "[#{Time.now}] Done."
  end

  desc "Snapshot savings and mortgage balances, derive contributions, check LVR milestones"
  task snapshot: :environment do
    puts "[#{Time.now}] Snapshotting balances..."
    SnapshotJob.perform_now
    LvrCheckJob.perform_now
    puts "[#{Time.now}] Done."
  end

  desc "Generate BudgetPeriod records from anchor date (ANCHOR_DATE=YYYY-MM-DD)"
  task generate_periods: :environment do
    anchor = ENV["ANCHOR_DATE"] || Setting[:anchor_date]
    abort "Set ANCHOR_DATE=YYYY-MM-DD or configure anchor_date in settings" unless anchor
    BudgetPeriod.generate_from_anchor(anchor)
    puts "Periods generated up to #{Date.today}."
  end
end

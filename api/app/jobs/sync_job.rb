class SyncJob < ApplicationJob
  queue_as :default

  def perform(days_back: 30)
    Rails.logger.info("[#{Time.now}] SyncJob started (days_back=#{days_back})")
    PocketsmithSyncService.new.sync_transactions(days_back: days_back)
    Rails.logger.info("[#{Time.now}] SyncJob complete")
  end
end

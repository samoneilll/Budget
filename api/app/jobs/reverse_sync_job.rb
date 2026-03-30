class ReverseSyncJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("[#{Time.now}] ReverseSyncJob started")
    PocketsmithReverseSyncService.new.sync!
    Rails.logger.info("[#{Time.now}] ReverseSyncJob complete")
  end
end

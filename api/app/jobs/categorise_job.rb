class CategoriseJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("[#{Time.now}] CategoriseJob started")
    service = ClaudeCategorizationService.new
    batches = 0
    while Transaction.unprocessed.not_transfers.exists?
      service.process_batch!
      batches += 1
    end
    Rails.logger.info("[#{Time.now}] CategoriseJob complete (#{batches} batches)")
    ReverseSyncJob.perform_later
  end
end

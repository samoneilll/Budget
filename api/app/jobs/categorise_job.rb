class CategoriseJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("[#{Time.now}] CategoriseJob started")
    failed_count = Transaction.where(processing_status: 'failed').update_all(processing_status: 'imported')
    Rails.logger.info("[#{Time.now}] CategoriseJob reset #{failed_count} failed transactions") if failed_count > 0
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

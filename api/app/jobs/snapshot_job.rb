class SnapshotJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("[#{Time.now}] SnapshotJob started")

    service = PocketsmithSyncService.new
    service.snapshot_savings_accounts
    service.snapshot_mortgages
    derive_contributions

    Rails.logger.info("[#{Time.now}] SnapshotJob complete")
  end

  private

  def derive_contributions
    period = BudgetPeriod.current.first
    return unless period

    SavingsAccount.all.each do |account|
      SavingsContribution.calculate_for_period(account, period)
    end
  end
end

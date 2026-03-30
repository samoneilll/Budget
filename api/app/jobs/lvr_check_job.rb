class LvrCheckJob < ApplicationJob
  queue_as :default

  def perform
    Mortgage.all.each do |mortgage|
      lvr = mortgage.lvr
      next unless lvr

      mortgage.lvr_milestones.unachieved.ordered.each do |milestone|
        next unless lvr <= milestone.lvr_target

        milestone.update!(achieved_at: Time.current)
        notify(mortgage, milestone)
        Rails.logger.info("[#{Time.now}] LVR milestone achieved: #{milestone.label} (#{milestone.lvr_display})")
      end
    end
  end

  private

  def notify(mortgage, milestone)
    ntfy_url = ENV.fetch("NTFY_URL", nil)
    return unless ntfy_url

    HTTP.headers(
      "Title"    => "Mortgage LVR Milestone",
      "Priority" => "high"
    ).post(ntfy_url, body: "LVR milestone reached: #{milestone.label} (#{milestone.lvr_display})")
  rescue HTTP::Error => e
    Rails.logger.error("[#{Time.now}] LvrCheckJob ntfy failed: #{e.message}")
  end
end

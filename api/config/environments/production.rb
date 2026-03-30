Rails.application.configure do
  config.eager_load = true
  config.log_level = :info
  config.log_tags = [:request_id]
  config.force_ssl = false
  config.solid_queue.connects_to = { database: { writing: :queue } }
end

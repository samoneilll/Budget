class PocketsmithReverseSyncService
  API_BASE  = "https://api.pocketsmith.com/v2"
  MAX_RETRY = 3

  def initialize
    @api_key = ENV.fetch("POCKETSMITH_API_KEY")
    @client  = HTTP.headers(
      "X-Developer-Key" => @api_key,
      "Accept"          => "application/json",
      "Content-Type"    => "application/json"
    )
    @user_id = get("#{API_BASE}/me")["id"]
  end

  def sync!
    sync_categories!
    sync_transactions!
  end

  private

  # ── Step 1: ensure every TransactionCategory has a matching PS category ──────

  def sync_categories!
    ps_cats = fetch_ps_categories.index_by { |c| c["title"].downcase }

    TransactionCategory.where(ps_category_id: nil).find_each do |tc|
      existing = ps_cats[tc.name.downcase]
      if existing
        tc.update_columns(ps_category_id: existing["id"])
        log "mapped existing PS category '#{tc.name}' → #{existing["id"]}"
      else
        created = create_ps_category(tc.name)
        tc.update_columns(ps_category_id: created["id"])
        log "created PS category '#{tc.name}' → #{created["id"]}"
      end
    end
  end

  def fetch_ps_categories
    flatten_categories(get("#{API_BASE}/users/#{@user_id}/categories"))
  rescue => e
    log "failed to fetch PS categories: #{e.message}"
    []
  end

  def flatten_categories(cats)
    cats.flat_map { |c| [c, *flatten_categories(c["children"] || [])] }
  end

  def create_ps_category(name)
    post("#{API_BASE}/users/#{@user_id}/categories", { title: name })
  end

  # ── Step 2: push category / is_transfer updates back to PS ───────────────────

  def sync_transactions!
    updated = 0
    errored = 0

    # Transactions needing a (re-)sync: categorised or haiku-flagged as transfer,
    # and either never synced or updated since last sync.
    scope = Transaction.where(
      "ps_category_synced_at IS NULL OR updated_at > ps_category_synced_at"
    ).where(
      "(processing_status = 'processed' OR manually_categorised = true OR haiku_is_transfer = true)"
    )

    scope.find_each do |txn|
      payload = build_payload(txn)
      next if payload.empty?

      begin
        patch_ps_transaction(txn.ps_id, payload)
        txn.update_columns(ps_category_synced_at: Time.current)
        updated += 1
      rescue => e
        log "failed to sync transaction #{txn.ps_id}: #{e.message}"
        errored += 1
      end
    end

    log "reverse sync complete: updated=#{updated} errored=#{errored}"
  end

  def build_payload(txn)
    payload = {}

    if txn.haiku_is_transfer && !txn.is_transfer
      # Haiku detected a transfer that PS doesn't know about — sync the flag only
      payload[:is_transfer] = true
    elsif !txn.effective_is_transfer
      # Normal categorised transaction — sync the category
      cat_id = txn.transaction_category&.ps_category_id
      payload[:category_id] = cat_id if cat_id
    end
    # is_transfer already true in PS → nothing to do

    payload
  end

  def patch_ps_transaction(ps_id, payload)
    response = with_retry do
      @client.put("#{API_BASE}/transactions/#{ps_id}", json: payload)
    end
    raise "PS API error #{response.status}" unless response.status.success?
    response.parse
  end

  # ── HTTP helpers ─────────────────────────────────────────────────────────────

  def get(url, params = {})
    with_retry { @client.get(url, params: params) }.parse
  end

  def post(url, body)
    response = with_retry { @client.post(url, json: body) }
    raise "PS API error #{response.status}: #{response.body}" unless response.status.success?
    response.parse
  end

  def with_retry
    attempts = 0
    begin
      attempts += 1
      yield
    rescue HTTP::Error => e
      retry if attempts < MAX_RETRY
      raise
    end
  end

  def log(msg)
    Rails.logger.info("[#{Time.now}] PocketsmithReverseSync: #{msg}")
  end
end

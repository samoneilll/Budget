class Transaction < ApplicationRecord
  belongs_to :pocketsmith_account,  optional: true
  belongs_to :transaction_category, optional: true
  has_one    :budget_category, through: :transaction_category

  enum :processing_status, {
    imported:  "imported",
    processed: "processed",
    failed:    "failed"
  }

  scope :unprocessed,   -> { where(processing_status: "imported") }
  scope :not_transfers, -> { where(is_transfer: false) }
  scope :for_period,    ->(period) { where(date: period.start_date..period.end_date) }
  scope :debits,        -> { where("amount < 0") }
  scope :credits,       -> { where("amount > 0") }

  validates :ps_id, presence: true, uniqueness: true
  validates :date, :amount, presence: true

  def self.from_pocketsmith(raw, pocketsmith_account:)
    new(
      ps_id:               raw["id"].to_s,
      date:                raw["date"],
      payee:               raw["payee"],
      original_payee:      raw["original_payee"],
      memo:                raw["memo"],
      amount:              raw["amount"],
      ps_type:             raw["type"],
      status:              raw["status"],
      is_transfer:         raw["is_transfer"] || false,
      pocketsmith_account: pocketsmith_account,
      ps_category:         raw.dig("category", "title"),
      processing_status:   "imported"
    )
  end

  def effective_is_transfer
    is_transfer || haiku_is_transfer
  end

  # Returns the effective category name — user override takes precedence
  def effective_category
    manually_categorised? ? transaction_category&.name : haiku_category
  end
end

class PocketsmithAccount < ApplicationRecord
  belongs_to :person, optional: true
  has_many :transactions
  has_one  :savings_account
  has_one  :mortgage

  validates :ps_id, presence: true, uniqueness: true
  validates :name,  presence: true

  def self.upsert_from_raw(raw)
    find_or_initialize_by(ps_id: raw["id"].to_s).tap do |a|
      a.name                 = raw["name"]
      a.number               = raw["number"]
      a.account_type         = raw["type"]
      a.institution          = raw.dig("institution", "title")
      a.current_balance      = raw["current_balance"]
      a.current_balance_date = raw["current_balance_date"]
      a.save!
    end
  end
end

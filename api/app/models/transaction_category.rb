class TransactionCategory < ApplicationRecord
  belongs_to :budget_category
  has_many :transactions, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end

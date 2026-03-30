module Api
  module V1
    class BudgetPeriodsController < BaseController
      def index
        render json: BudgetPeriod.recent.limit(12)
      end

      def show
        render json: period
      end

      def summary
        category_totals = Transaction
          .not_transfers
          .where(date: period.start_date..period.end_date)
          .where.not(budget_category_id: nil)
          .group(:budget_category_id)
          .sum(:amount)

        result = BudgetCategory.all.order(:name).map do |cat|
          spent = category_totals[cat.id]&.abs || 0
          {
            id:                cat.id,
            name:              cat.name,
            fortnightly_amount: cat.fortnightly_amount,
            spent:             spent
          }
        end

        render json: { period: period, categories: result }
      end

      private

      def period
        @period ||= if params[:id] == "current"
          BudgetPeriod.current.first || BudgetPeriod.recent.first
        else
          BudgetPeriod.find(params[:id])
        end
      end
    end
  end
end
